//
//  OGDTrianglesViewController.m
//  SwipeOpenGLTriangles
//
//  Created by Chris Miles on 23/07/12.
//  Copyright (c) 2012 Chris Miles. All rights reserved.
//
//  MIT Licensed (http://opensource.org/licenses/mit-license.php):
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "OGDTrianglesViewController.h"


#define kNumVertices 24

/*
   3       2
    +-----+
    |    /|
    |   / |
    |  /  |
    | /   |
    |/    |
    +-----+
   1       4
 */

static GLfloat gTrianglesBoxVertexData[kNumVertices*3] =
{
    // position x, position y, position z
    
    // Front
    -0.5f, -0.5f, 0.5f, // 1
     0.5f,  0.5f, 0.5f, // 2
    -0.5f,  0.5f, 0.5f, // 3
    
    -0.5f, -0.5f, 0.5f, // 1
     0.5f, -0.5f, 0.5f, // 4
     0.5f,  0.5f, 0.5f, // 2
    
    // Right side
     0.5f, -0.5f,  0.5f, // 1
     0.5f,  0.5f, -0.5f, // 2
     0.5f,  0.5f,  0.5f, // 3
    
     0.5f, -0.5f,  0.5f, // 1
     0.5f, -0.5f, -0.5f, // 4
     0.5f,  0.5f, -0.5f, // 2
    
    // Back
     0.5f, -0.5f, -0.5f,
    -0.5f,  0.5f, -0.5f,
     0.5f,  0.5f, -0.5f,
    
     0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f,  0.5f, -0.5f,
    
    // Left side
    -0.5f,  0.5f,  0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f,  0.5f,
    
    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
};

static GLfloat gTrianglesFlatVertexData[kNumVertices*3] =
{
    // position x, position y, position z

    // Front
    -0.5f, -0.5+1.2f, 0.0f,
     0.5f,  0.5+1.2f, 0.0f,
    -0.5f,  0.5+1.2f, 0.0f,
    
    -0.5f, -0.5-1.2f, 0.0f,
     0.5f, -0.5-1.2f, 0.0f,
     0.5f,  0.5-1.2f, 0.0f,
    
    // Right side
    -0.5+1.2f, -0.5+0.6f, 0.0f,
     0.5+1.2f,  0.5+0.6f, 0.0f,
    -0.5+1.2f,  0.5+0.6f, 0.0f,
    
    -0.5+1.2f, -0.5-0.6f, 0.0f,
     0.5+1.2f, -0.5-0.6f, 0.0f,
     0.5+1.2f,  0.5-0.6f, 0.0f,
    
    // Back
    -0.5-1.2f, -0.5+0.6f, 0.0f,
     0.5-1.2f,  0.5+0.6f, 0.0f,
    -0.5-1.2f,  0.5+0.6f, 0.0f,
    
    -0.5-1.2f, -0.5-0.6f, 0.0f,
     0.5-1.2f, -0.5-0.6f, 0.0f,
     0.5-1.2f,  0.5-0.6f, 0.0f,
    
    // Left side
     0.5f+0.1f,  0.5f, 0.0f,
    -0.5f+0.1f, -0.5f, 0.0f,
     0.5f+0.1f, -0.5f, 0.0f,
    
     0.5f-0.1f,  0.5f, 0.0f,
    -0.5f-0.1f,  0.5f, 0.0f,
    -0.5f-0.1f, -0.5f, 0.0f,
};

static float QuadraticEaseInOut(float p);


@interface OGDTrianglesViewController () {
    float _rotation;
    float _transition;
    float _transitionDirection;
    BOOL _transitionEnabled;
    
    GLuint _trianglesVertexArray;
    GLuint _trianglesVertexBuffer;
    
    GLfloat *_vertexData;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation OGDTrianglesViewController


@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"GL_TRIANGLES";
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    self.preferredFramesPerSecond = 60;

    [self setupGL];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);

    self.effect = [[GLKBaseEffect alloc] init];
    
    _vertexData = calloc(kNumVertices*3, sizeof(GLfloat));
    _transition = 0.0f;
    _transitionDirection = -1.0f;
    [self loadAnimatedVertexData];
    
    /* Vertex Data Arrays */
    glGenVertexArraysOES(1, &_trianglesVertexArray);
    glBindVertexArrayOES(_trianglesVertexArray);
    
    glGenBuffers(1, &_trianglesVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _trianglesVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*kNumVertices*3, _vertexData, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, (char *)0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_trianglesVertexBuffer);
    glDeleteVertexArraysOES(1, &_trianglesVertexArray);
    
    self.effect = nil;
    
    free(_vertexData); _vertexData = NULL;
}


#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    if (_transitionEnabled) {
	_transition += self.timeSinceLastUpdate * 0.4f * _transitionDirection;
	if (_transition > 1.0f) _transition = 1.0f;
	else if (_transition < 0.0f) _transition = 0.0f;
	
	[self loadAnimatedVertexData];
	
	if (_transition == 0.0f || _transition == 1.0f) _transitionEnabled = NO;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*kNumVertices*3, _vertexData, GL_DYNAMIC_DRAW);
    glDrawArrays(GL_TRIANGLES, 0, kNumVertices);
}


#pragma mark - Vertex animation

- (void)loadAnimatedVertexData
{
    float animTime = QuadraticEaseInOut(_transition);
    
    for (int i=0; i<kNumVertices*3; i++) {
	GLfloat startVertex = gTrianglesFlatVertexData[i];
	GLfloat endVertex = gTrianglesBoxVertexData[i];
	GLfloat vertex = startVertex + (endVertex - startVertex) * animTime;
	_vertexData[i] = vertex;
    }
}


#pragma mark - Touches

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (! _transitionEnabled) {
	_transitionDirection = - _transitionDirection;
	_transitionEnabled = YES;
    }
}

@end


#pragma mark - Helper Functions

// Borrowed from AHEasing
// Modeled after the piecewise quadratic
// y = (1/2)((2x)^2)             ; [0, 0.5)
// y = -(1/2)((2x-1)*(2x-3) - 1) ; [0.5, 1]
static float QuadraticEaseInOut(float p)
{
    if(p < 0.5)
    {
	return 2 * p * p;
    }
    else
    {
	return (-2 * p * p) + (4 * p) - 1;
    }
}

