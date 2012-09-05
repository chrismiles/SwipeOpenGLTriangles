//
//  OGDTrianglesLightingViewController.m
//  SwipeOpenGLTriangles
//
//  Created by Chris Miles on 25/07/12.
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

#import "OGDTrianglesLightingViewController.h"

typedef enum {
    OGDTrianglesFillModeConstantColor = 0,
    OGDTrianglesFillModeVertexColors,
    OGDTrianglesFillModeTextured
} OGDTrianglesFillMode;

typedef struct _vertexStruct
{
    GLfloat position[3];
    GLfloat normals[3];
    GLubyte color[4];
} vertexStruct;

#define kBytesPerVertex (sizeof(vertexStruct))
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

static GLfloat gTrianglesVertexBoxPositionNormalData[kNumVertices*6] =
{
    // position x, position y, position z,	normal x, normal y, normal z
    
    // Front
    -0.5f, -0.5f, 0.5f,	    0.0f, 0.0f, 1.0f, // 1
     0.5f,  0.5f, 0.5f,	    0.0f, 0.0f, 1.0f, // 2
    -0.5f,  0.5f, 0.5f,	    0.0f, 0.0f, 1.0f, // 3
    
    -0.5f, -0.5f, 0.5f,	    0.0f, 0.0f, 1.0f, // 1
     0.5f, -0.5f, 0.5f,	    0.0f, 0.0f, 1.0f, // 4
     0.5f,  0.5f, 0.5f,	    0.0f, 0.0f, 1.0f, // 2
    
    // Right side
     0.5f, -0.5f,  0.5f,    1.0f, 0.0f, 0.0f, // 1
     0.5f,  0.5f, -0.5f,    1.0f, 0.0f, 0.0f, // 2
     0.5f,  0.5f,  0.5f,    1.0f, 0.0f, 0.0f, // 3
    
     0.5f, -0.5f,  0.5f,    1.0f, 0.0f, 0.0f, // 1
     0.5f, -0.5f, -0.5f,    1.0f, 0.0f, 0.0f, // 4
     0.5f,  0.5f, -0.5f,    1.0f, 0.0f, 0.0f, // 2
    
    // Back
     0.5f, -0.5f, -0.5f,    0.0f, 0.0f, -1.0f,
    -0.5f,  0.5f, -0.5f,    0.0f, 0.0f, -1.0f,
     0.5f,  0.5f, -0.5f,    0.0f, 0.0f, -1.0f,
    
     0.5f, -0.5f, -0.5f,    0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,    0.0f, 0.0f, -1.0f,
    -0.5f,  0.5f, -0.5f,    0.0f, 0.0f, -1.0f,
    
    // Left side
    -0.5f,  0.5f,  0.5f,   -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,   -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,   -1.0f, 0.0f, 0.0f,
    
    -0.5f,  0.5f,  0.5f,   -1.0f, 0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,   -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,   -1.0f, 0.0f, 0.0f,
};

static GLfloat gTrianglesVertexFlatPositionNormalData[kNumVertices*6] =
{
    // position x, position y, position z,	normal x, normal y, normal z
    
    // Front
    -0.5f, -0.5+1.2f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5f,  0.5+1.2f, 0.0f,	    0.0f, 0.0f, 1.0f,
    -0.5f,  0.5+1.2f, 0.0f,	    0.0f, 0.0f, 1.0f,
    
    -0.5f, -0.5-1.2f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5f, -0.5-1.2f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5f,  0.5-1.2f, 0.0f,	    0.0f, 0.0f, 1.0f,
    
    // Right side
    -0.5+1.2f, -0.5+0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5+1.2f,  0.5+0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
    -0.5+1.2f,  0.5+0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
    
    -0.5+1.2f, -0.5-0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5+1.2f, -0.5-0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5+1.2f,  0.5-0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
    
    // Back
    -0.5-1.2f, -0.5+0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5-1.2f,  0.5+0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
    -0.5-1.2f,  0.5+0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
    
    -0.5-1.2f, -0.5-0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5-1.2f, -0.5-0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5-1.2f,  0.5-0.6f, 0.0f,	    0.0f, 0.0f, 1.0f,
    
    // Left side
     0.5f+0.1f,  0.5f, 0.0f,	    0.0f, 0.0f, 1.0f,
    -0.5f+0.1f, -0.5f, 0.0f,	    0.0f, 0.0f, 1.0f,
     0.5f+0.1f, -0.5f, 0.0f,	    0.0f, 0.0f, 1.0f,
    
     0.5f-0.1f,  0.5f, 0.0f,	    0.0f, 0.0f, 1.0f,
    -0.5f-0.1f,  0.5f, 0.0f,	    0.0f, 0.0f, 1.0f,
    -0.5f-0.1f, -0.5f, 0.0f,	    0.0f, 0.0f, 1.0f,
};

static GLubyte gTrianglesVertexColorData[kNumVertices*4] =
{
    // red, green, blue, alpha
    
    // Front
    255,   0,   0, 255, // 1
    255, 255,   0, 255, // 2
    255, 255, 255, 255, // 3
    
    255,   0,   0, 255, // 1
      0, 255,   0, 255, // 4
    255, 255,   0, 255, // 2
    
    // Right side
      0, 255,   0, 255, // 1
      0, 255, 255, 255, // 2
    255, 255,   0, 255, // 3
    
      0, 255,   0, 255, // 1
     51,  51,  51, 255, // 4
      0, 255, 255, 255, // 2
    
    // Back
      0,   0, 255, 255, // 1
      0, 255, 255, 255, // 2
     51, 127, 178, 255, // 3
    
      0,   0, 255, 255, // 1
     51,  51,  51, 255, // 4
      0, 255, 255, 255, // 2
    
    // Left side
    255,   0,   0, 255, // 1
    255,   0, 255, 255, // 2
    255, 255, 255, 255, // 3
    
    255,   0,   0, 255, // 1
      0,   0, 255, 255, // 4
    255,   0, 255, 255, // 2
};

static float QuadraticEaseInOut(float p);


@interface OGDTrianglesLightingViewController () {
    float _rotation;
    float _transition;
    float _transitionDirection;
    BOOL _transitionEnabled;
    
    GLuint _trianglesVertexArray;
    GLuint _trianglesVertexBuffer;
    
    vertexStruct *_vertexData;
    
    OGDTrianglesFillMode _trianglesFillMode;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;


@end


@implementation OGDTrianglesLightingViewController


@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"GL_TRIANGLES + Lighting";
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
    
    self.toolbarItems = [self makeToolbarItems];
}

- (NSArray *)makeToolbarItems
{
    UIBarButtonItem *flexItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UISegmentedControl *fillModeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Constant Colour", @"Vertex Colours", nil]];
    fillModeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    fillModeControl.selectedSegmentIndex = 0;
    [fillModeControl addTarget:self action:@selector(fillModeControlAction:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *fillModeItem = [[UIBarButtonItem alloc] initWithCustomView:fillModeControl];

    UIBarButtonItem *flexItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UISegmentedControl *lightControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Light On", @"Light Off", nil]];
    lightControl.segmentedControlStyle = UISegmentedControlStyleBar;
    lightControl.selectedSegmentIndex = 0;
    [lightControl addTarget:self action:@selector(lightControlAction:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *lightItem = [[UIBarButtonItem alloc] initWithCustomView:lightControl];

    UIBarButtonItem *flexItem3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    return [NSArray arrayWithObjects:flexItem1, fillModeItem, flexItem2, lightItem, flexItem3, nil];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
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
    self.effect.colorMaterialEnabled = YES;
    
    self.effect.constantColor = GLKVector4Make(1.0f, 1.0f, 0.0f, 1.0f); // yellow
    self.effect.useConstantColor = YES;
    
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.ambientColor = GLKVector4Make(0.1f, 0.1f, 0.1f, 1.0f);
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.light0.position = GLKVector4Make(0.0f, 0.0f, 1.0f, 0.0f);
    self.effect.lightModelTwoSided = YES;
    
    
    _vertexData = calloc(kNumVertices, kBytesPerVertex);
    _transition = 0.0f;
    _transitionDirection = -1.0f;
    [self loadVertexColors];
    [self loadAnimatedVertexData];
    
    /* Vertex Data Arrays */
    glGenVertexArraysOES(1, &_trianglesVertexArray);
    glBindVertexArrayOES(_trianglesVertexArray);
    
    glGenBuffers(1, &_trianglesVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _trianglesVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, kNumVertices*kBytesPerVertex, _vertexData, GL_DYNAMIC_DRAW);
    
    GLsizei stride = kBytesPerVertex;
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, (void *)offsetof(vertexStruct, position));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, (void *)offsetof(vertexStruct, normals));
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, (void *)offsetof(vertexStruct, color));
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
    
    if (self.effect.useConstantColor) {
	glDisableVertexAttribArray(GLKVertexAttribColor);
    }
    else {
	glEnableVertexAttribArray(GLKVertexAttribColor);
    }
    
    glBufferData(GL_ARRAY_BUFFER, kNumVertices*kBytesPerVertex, _vertexData, GL_DYNAMIC_DRAW);
    glDrawArrays(GL_TRIANGLES, 0, kNumVertices);
}


#pragma mark - Vertex data

- (void)loadVertexColors
{
    for (int i=0; i<kNumVertices; i++) {
	vertexStruct vertex;
	for (int c=0; c<4; c++) {
	    GLubyte colorComponent = gTrianglesVertexColorData[i*4 + c];
	    vertex.color[c] = colorComponent;
	}
	_vertexData[i] = vertex;
    }
}

- (void)loadAnimatedVertexData
{
    float animTime = QuadraticEaseInOut(_transition);
    
    for (int i=0; i<kNumVertices; i++) {
	vertexStruct vertex = _vertexData[i];
	for (int p=0; p<3; p++) {
	    GLfloat startPosition = gTrianglesVertexFlatPositionNormalData[i*6 + p];
	    GLfloat endPosition = gTrianglesVertexBoxPositionNormalData[i*6 + p];
	    GLfloat position = startPosition + (endPosition - startPosition) * animTime;
	    vertex.position[p] = position;
	}
	for (int n=0; n<3; n++) {
	    GLfloat startNormal = gTrianglesVertexFlatPositionNormalData[3 + i*6 + n];
	    GLfloat endNormal = gTrianglesVertexBoxPositionNormalData[3 + i*6 + n];
	    GLfloat normal = startNormal + (endNormal - startNormal) * animTime;
	    vertex.normals[n] = normal;
	}
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


#pragma mark - Fill mode control

- (void)fillModeControlAction:(id)sender
{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    [self updateTrianglesFillMode:control.selectedSegmentIndex];
}

- (void)updateTrianglesFillMode:(OGDTrianglesFillMode)trianglesFillMode
{
    self.effect.useConstantColor = (trianglesFillMode == OGDTrianglesFillModeConstantColor);

    _trianglesFillMode = trianglesFillMode;
}


#pragma mark - Light control

- (void)lightControlAction:(id)sender
{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    [self setLightEnabled: ! (BOOL)control.selectedSegmentIndex];
}

- (void)setLightEnabled:(BOOL)lightEnabled
{
    if (lightEnabled) {
	self.effect.light0.enabled = GL_TRUE;
    }
    else {
	self.effect.light0.enabled = GL_FALSE;
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

