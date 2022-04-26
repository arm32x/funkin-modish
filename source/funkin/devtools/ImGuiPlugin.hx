package funkin.devtools;

#if (MODISH_DEV && cpp)
import flixel.FlxBasic;
import flixel.FlxG;
import imguicpp.ImGui;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.RenderEvent;
import openfl.ui.Keyboard as OpenFLKeyboard;
import openfl.ui.KeyLocation;

// Bindings to ImGui backends. Note that imgui-hx must be used at least once
// in the file for the include paths to resolve.
@:include("imgui_impl_sdl.h") @:native("SDL_Window") extern class SDLWindow {}
@:include("imgui_impl_sdl.h") @:native("SDL_Event") extern class SDLEvent {}

@:include("imgui_impl_sdl.h")
extern class ImGui_ImplSDL2
{
    @:native("ImGui_ImplSDL2_InitForOpenGL")
    static function initForOpenGL(window:cpp.Star<SDLWindow>, sdlGlContext:cpp.Star<cpp.Void>):Bool;

    @:native("ImGui_ImplSDL2_Shutdown")
    static function shutdown():Void;
    
    @:native("ImGui_ImplSDL2_NewFrame")
    static function newFrame():Void;
    
    @:native("ImGui_ImplSDL2_ProcessEvent")
    static function processEvent(event:cpp.ConstStar<SDLEvent>):Bool;
}

@:include("imgui_impl_opengl3.h")
extern class ImGui_ImplOpenGL3
{
    @:native("ImGui_ImplOpenGL3_Init")
    static function init(?glslVersion:cpp.ConstCharStar):Bool;
    
    @:native("ImGui_ImplOpenGL3_Shutdown")
    static function shutdown():Void;
    
    @:native("ImGui_ImplOpenGL3_NewFrame")
    static function newFrame():Void;
    
    @:native("ImGui_ImplOpenGL3_RenderDrawData")
    static function renderDrawData(drawData:cpp.Star<ImDrawData>):Void;
}

// This code is a slightly modified version of Lime's internal Window and
// SDLWindow class definitions. It is here because the header these classes are
// from is not accessible to this project.
//
// See original source code here:
// https://github.com/native-toolkit/lime/blob/develop/project/src/backend/sdl/SDLWindow.h
@:headerCode("
typedef void* SDL_GLContext;
struct SDL_Renderer;
struct SDL_Texture;
struct SDL_Window;

namespace lime {
    class Application;
    class Cursor;
    class DisplayMode;
    class ImageBuffer;
    class Rectangle;
    
    class Window {
        public:
            virtual ~Window () {};

            virtual void Alert (const char* message, const char* title) = 0;
            virtual void Close () = 0;
            virtual void ContextFlip () = 0;
            virtual void* ContextLock (bool useCFFIValue) = 0;
            virtual void ContextMakeCurrent () = 0;
            virtual void ContextUnlock () = 0;
            virtual void Focus () = 0;
            virtual void* GetContext () = 0;
            virtual const char* GetContextType () = 0;
            virtual int GetDisplay () = 0;
            virtual void GetDisplayMode (DisplayMode* displayMode) = 0;
            virtual int GetHeight () = 0;
            virtual uint32_t GetID () = 0;
            virtual bool GetMouseLock () = 0;
            virtual double GetScale () = 0;
            virtual bool GetTextInputEnabled () = 0;
            virtual int GetWidth () = 0;
            virtual int GetX () = 0;
            virtual int GetY () = 0;
            virtual void Move (int x, int y) = 0;
            virtual void ReadPixels (ImageBuffer *buffer, Rectangle *rect) = 0;
            virtual void Resize (int width, int height) = 0;
            virtual bool SetBorderless (bool borderless) = 0;
            virtual void SetCursor (Cursor cursor) = 0;
            virtual void SetDisplayMode (DisplayMode* displayMode) = 0;
            virtual bool SetFullscreen (bool fullscreen) = 0;
            virtual void SetIcon (ImageBuffer *imageBuffer) = 0;
            virtual bool SetMaximized (bool minimized) = 0;
            virtual bool SetMinimized (bool minimized) = 0;
            virtual void SetMouseLock (bool mouseLock) = 0;
            virtual bool SetResizable (bool resizable) = 0;
            virtual void SetTextInputEnabled (bool enable) = 0;
            virtual const char* SetTitle (const char* title) = 0;
            virtual void WarpMouse (int x, int y) = 0;

            Application* currentApplication;
            int flags;
    };

    class SDLWindow : public Window {
        public:
            SDLWindow (Application* application, int width, int height, int flags, const char* title);
            ~SDLWindow ();

            virtual void Alert (const char* message, const char* title);
            virtual void Close ();
            virtual void ContextFlip ();
            virtual void* ContextLock (bool useCFFIValue);
            virtual void ContextMakeCurrent ();
            virtual void ContextUnlock ();
            virtual void Focus ();
            virtual void* GetContext ();
            virtual const char* GetContextType ();
            virtual int GetDisplay ();
            virtual void GetDisplayMode (DisplayMode* displayMode);
            virtual int GetHeight ();
            virtual uint32_t GetID ();
            virtual bool GetMouseLock ();
            virtual double GetScale ();
            virtual bool GetTextInputEnabled ();
            virtual int GetWidth ();
            virtual int GetX ();
            virtual int GetY ();
            virtual void Move (int x, int y);
            virtual void ReadPixels (ImageBuffer *buffer, Rectangle *rect);
            virtual void Resize (int width, int height);
            virtual bool SetBorderless (bool borderless);
            virtual void SetCursor (Cursor cursor);
            virtual void SetDisplayMode (DisplayMode* displayMode);
            virtual bool SetFullscreen (bool fullscreen);
            virtual void SetIcon (ImageBuffer *imageBuffer);
            virtual bool SetMaximized (bool maximized);
            virtual bool SetMinimized (bool minimized);
            virtual void SetMouseLock (bool mouseLock);
            virtual bool SetResizable (bool resizable);
            virtual void SetTextInputEnabled (bool enabled);
            virtual const char* SetTitle (const char* title);
            virtual void WarpMouse (int x, int y);

            SDL_Renderer* sdlRenderer;
            SDL_Texture* sdlTexture;
            SDL_Window* sdlWindow;

            SDL_GLContext context;
            int contextHeight;
            int contextWidth;
    };
}
")
@:headerInclude("hx/CFFIPrime.h")
class ImGuiPlugin extends FlxBasic
{
    private static final MOUSE_EVENTS = [
        MouseEvent.MOUSE_WHEEL,
        MouseEvent.MOUSE_DOWN,
        MouseEvent.MOUSE_UP,
        MouseEvent.RIGHT_MOUSE_DOWN,
        MouseEvent.RIGHT_MOUSE_UP,
        MouseEvent.MIDDLE_MOUSE_DOWN,
        MouseEvent.MIDDLE_MOUSE_UP
    ];
    private static final KEYBOARD_EVENTS = [
        KeyboardEvent.KEY_DOWN,
        KeyboardEvent.KEY_UP
    ];

    private static final KEYCODE_MAP: Map<Int, ImGuiKey> = [
        OpenFLKeyboard.TAB => ImGuiKey.Tab,
        OpenFLKeyboard.LEFT => ImGuiKey.LeftArrow,
        OpenFLKeyboard.RIGHT => ImGuiKey.RightArrow,
        OpenFLKeyboard.UP => ImGuiKey.UpArrow,
        OpenFLKeyboard.DOWN => ImGuiKey.DownArrow,
        OpenFLKeyboard.PAGE_UP => ImGuiKey.PageUp,
        OpenFLKeyboard.PAGE_DOWN => ImGuiKey.PageDown,
        OpenFLKeyboard.HOME => ImGuiKey.Home,
        OpenFLKeyboard.END => ImGuiKey.End,
        OpenFLKeyboard.INSERT => ImGuiKey.Insert,
        OpenFLKeyboard.DELETE => ImGuiKey.Delete,
        OpenFLKeyboard.BACKSPACE => ImGuiKey.Backspace,
        OpenFLKeyboard.SPACE => ImGuiKey.Space,
        OpenFLKeyboard.ENTER => ImGuiKey.Enter,
        OpenFLKeyboard.ESCAPE => ImGuiKey.Escape,
        // Modifier keys are handled separately to differentiate between
        // left and right keys.
        OpenFLKeyboard.NUMBER_0 => ImGuiKey._0,
        OpenFLKeyboard.NUMBER_1 => ImGuiKey._1,
        OpenFLKeyboard.NUMBER_2 => ImGuiKey._2,
        OpenFLKeyboard.NUMBER_3 => ImGuiKey._3,
        OpenFLKeyboard.NUMBER_4 => ImGuiKey._4,
        OpenFLKeyboard.NUMBER_5 => ImGuiKey._5,
        OpenFLKeyboard.NUMBER_6 => ImGuiKey._6,
        OpenFLKeyboard.NUMBER_7 => ImGuiKey._7,
        OpenFLKeyboard.NUMBER_8 => ImGuiKey._8,
        OpenFLKeyboard.NUMBER_9 => ImGuiKey._9,
        OpenFLKeyboard.A => ImGuiKey.A,
        OpenFLKeyboard.B => ImGuiKey.B,
        OpenFLKeyboard.C => ImGuiKey.C,
        OpenFLKeyboard.D => ImGuiKey.D,
        OpenFLKeyboard.E => ImGuiKey.E,
        OpenFLKeyboard.F => ImGuiKey.F,
        OpenFLKeyboard.G => ImGuiKey.G,
        OpenFLKeyboard.H => ImGuiKey.H,
        OpenFLKeyboard.I => ImGuiKey.I,
        OpenFLKeyboard.J => ImGuiKey.J,
        OpenFLKeyboard.K => ImGuiKey.K,
        OpenFLKeyboard.L => ImGuiKey.L,
        OpenFLKeyboard.M => ImGuiKey.M,
        OpenFLKeyboard.N => ImGuiKey.N,
        OpenFLKeyboard.O => ImGuiKey.O,
        OpenFLKeyboard.P => ImGuiKey.P,
        OpenFLKeyboard.Q => ImGuiKey.Q,
        OpenFLKeyboard.R => ImGuiKey.R,
        OpenFLKeyboard.S => ImGuiKey.S,
        OpenFLKeyboard.T => ImGuiKey.T,
        OpenFLKeyboard.U => ImGuiKey.U,
        OpenFLKeyboard.V => ImGuiKey.V,
        OpenFLKeyboard.W => ImGuiKey.W,
        OpenFLKeyboard.X => ImGuiKey.X,
        OpenFLKeyboard.Y => ImGuiKey.Y,
        OpenFLKeyboard.Z => ImGuiKey.Z,
        OpenFLKeyboard.F1 => ImGuiKey.F1,
        OpenFLKeyboard.F2 => ImGuiKey.F2,
        OpenFLKeyboard.F3 => ImGuiKey.F3,
        OpenFLKeyboard.F4 => ImGuiKey.F4,
        OpenFLKeyboard.F5 => ImGuiKey.F5,
        OpenFLKeyboard.F6 => ImGuiKey.F6,
        OpenFLKeyboard.F7 => ImGuiKey.F7,
        OpenFLKeyboard.F8 => ImGuiKey.F8,
        OpenFLKeyboard.F9 => ImGuiKey.F9,
        OpenFLKeyboard.F10 => ImGuiKey.F10,
        OpenFLKeyboard.F11 => ImGuiKey.F11,
        OpenFLKeyboard.F12 => ImGuiKey.F12,
        OpenFLKeyboard.QUOTE => ImGuiKey.Apostrophe,
        OpenFLKeyboard.COMMA => ImGuiKey.Comma,
        OpenFLKeyboard.MINUS => ImGuiKey.Minus,
        OpenFLKeyboard.PERIOD => ImGuiKey.Period,
        OpenFLKeyboard.SLASH => ImGuiKey.Slash,
        OpenFLKeyboard.SEMICOLON => ImGuiKey.Semicolon,
        OpenFLKeyboard.EQUAL => ImGuiKey.Equal,
        OpenFLKeyboard.LEFTBRACKET => ImGuiKey.LeftBracket,
        OpenFLKeyboard.BACKSLASH => ImGuiKey.Backslash,
        OpenFLKeyboard.RIGHTBRACKET => ImGuiKey.RightBracket,
        OpenFLKeyboard.BACKQUOTE => ImGuiKey.GraveAccent,
        OpenFLKeyboard.CAPS_LOCK => ImGuiKey.CapsLock,
        OpenFLKeyboard.NUMPAD_0 => ImGuiKey.Keypad0,
        OpenFLKeyboard.NUMPAD_1 => ImGuiKey.Keypad1,
        OpenFLKeyboard.NUMPAD_2 => ImGuiKey.Keypad2,
        OpenFLKeyboard.NUMPAD_3 => ImGuiKey.Keypad3,
        OpenFLKeyboard.NUMPAD_4 => ImGuiKey.Keypad4,
        OpenFLKeyboard.NUMPAD_5 => ImGuiKey.Keypad5,
        OpenFLKeyboard.NUMPAD_6 => ImGuiKey.Keypad6,
        OpenFLKeyboard.NUMPAD_7 => ImGuiKey.Keypad7,
        OpenFLKeyboard.NUMPAD_8 => ImGuiKey.Keypad8,
        OpenFLKeyboard.NUMPAD_9 => ImGuiKey.Keypad9,
        OpenFLKeyboard.NUMPAD_DECIMAL => ImGuiKey.KeypadDecimal,
        OpenFLKeyboard.NUMPAD_DIVIDE => ImGuiKey.KeypadDivide,
        OpenFLKeyboard.NUMPAD_MULTIPLY => ImGuiKey.KeypadMultiply,
        OpenFLKeyboard.NUMPAD_SUBTRACT => ImGuiKey.KeypadSubtract,
        OpenFLKeyboard.NUMPAD_ADD => ImGuiKey.KeypadAdd,
        OpenFLKeyboard.NUMPAD_ENTER => ImGuiKey.KeypadEnter,
    ];
    
    public function new()
    {
        super();

        // Use linc_sdl so the compiler will actually compile it.
        sdl.SDL.getRevisionNumber();
        
        ImGui.createContext();
        ImGui.styleColorsDark();
        
        var sdlWindowPtr = getSDLWindowPtr();
        var sdlGLContext = getSDLGLContext();
        ImGui_ImplSDL2.initForOpenGL(sdlWindowPtr, sdlGLContext);
        ImGui_ImplOpenGL3.init("#version 130");
        
        FlxG.stage.addChild(new ImGuiSprite());
        
        // Unfortunately, SDL events are buried too far in Lime internals to
        // retrieve, so we have to handle input manually using OpenFL.
        for (event in MOUSE_EVENTS)
            FlxG.stage.addEventListener(event, handleMouseEvent, false, 1000);
        for (event in KEYBOARD_EVENTS)
            FlxG.stage.addEventListener(event, handleKeyboardEvent, false, 1000);
    }
    
    private function handleMouseEvent(event:MouseEvent)
    {
        var io = ImGui.getIO();

        switch (event.type)
        {
            case MouseEvent.MOUSE_WHEEL:
                // FIXME: Support horizontal scrolling.
                var wheelY = (event.delta > 0) ? 1.0 : (event.delta < 0) ? -1.0 : 0.0;
                io.addMouseWheelEvent(0.0, wheelY);

            case MouseEvent.MOUSE_DOWN:
                io.addMouseButtonEvent(ImGuiMouseButton.Left, true);
            case MouseEvent.MOUSE_UP:
                io.addMouseButtonEvent(ImGuiMouseButton.Left, false);
            case MouseEvent.RIGHT_MOUSE_DOWN:
                io.addMouseButtonEvent(ImGuiMouseButton.Right, true);
            case MouseEvent.RIGHT_MOUSE_UP:
                io.addMouseButtonEvent(ImGuiMouseButton.Right, false);
            case MouseEvent.MIDDLE_MOUSE_DOWN:
                io.addMouseButtonEvent(ImGuiMouseButton.Middle, true);
            case MouseEvent.MIDDLE_MOUSE_UP:
                io.addMouseButtonEvent(ImGuiMouseButton.Middle, false);
        }

        // Since this event handler has a high priority, it will run before
        // Flixel, allowing us to prevent Flixel from ever receiving the event.
        if (io.wantCaptureMouse)
            event.stopImmediatePropagation();
    }
    
    private function handleKeyboardEvent(event:KeyboardEvent)
    {
        var io = ImGui.getIO();
        
        // Update modifier keys.
        // FIXME: Properly report the Windows/Command/Super key.
        io.addKeyEvent(ImGuiKey.ModCtrl, event.ctrlKey);
        io.addKeyEvent(ImGuiKey.ModShift, event.shiftKey);
        io.addKeyEvent(ImGuiKey.ModAlt, event.altKey);
        
        var key:Null<ImGuiKey> = switch (event.keyCode)
        {
            case OpenFLKeyboard.CONTROL if (event.keyLocation == KeyLocation.LEFT):
                ImGuiKey.LeftCtrl;
            case OpenFLKeyboard.CONTROL if (event.keyLocation == KeyLocation.RIGHT):
                ImGuiKey.RightCtrl;
            case OpenFLKeyboard.SHIFT if (event.keyLocation == KeyLocation.LEFT):
                ImGuiKey.LeftShift;
            case OpenFLKeyboard.SHIFT if (event.keyLocation == KeyLocation.RIGHT):
                ImGuiKey.RightShift;
            case OpenFLKeyboard.ALTERNATE if (event.keyLocation == KeyLocation.LEFT):
                ImGuiKey.LeftAlt;
            case OpenFLKeyboard.ALTERNATE if (event.keyLocation == KeyLocation.RIGHT):
                ImGuiKey.RightAlt;
            
            case keyCode:
                KEYCODE_MAP.get(keyCode);
        }
        if (key != null)
            io.addKeyEvent(key, event.type == KeyboardEvent.KEY_DOWN);

        // Since this event handler has a high priority, it will run before
        // Flixel, allowing us to prevent Flixel from ever receiving the event.
        if (io.wantCaptureKeyboard)
            event.stopImmediatePropagation();
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        ImGui_ImplOpenGL3.newFrame();
        ImGui_ImplSDL2.newFrame();
        ImGui.newFrame();
        
        ImGui.showDemoWindow();
        
        ImGui.begin("Test Window");
        ImGui.text("This is a test window.");
        ImGui.end();
        
        ImGui.render();
    }
    
    override public function destroy()
    {
        ImGui_ImplOpenGL3.shutdown();
        ImGui_ImplSDL2.shutdown();
        ImGui.destroyContext();

        for (event in MOUSE_EVENTS)
            FlxG.stage.removeEventListener(event, handleMouseEvent);
        for (event in KEYBOARD_EVENTS)
            FlxG.stage.removeEventListener(event, handleKeyboardEvent);
    }
    
    /**
        Get a pointer to the SDL window used internally by Lime.
        
        This function will throw an exception if the window is not backed by
        SDL, such as on Adobe AIR, Flash, and HTML5.
    **/
    private static function getSDLWindowPtr():cpp.Star<SDLWindow>
    {
        // Step 1: Dig through Lime to get the NativeWindow.
        var window = FlxG.stage.application.window;
        var windowBackend = @:privateAccess window.__backend;
        var nativeWindow = cast(windowBackend, lime._internal.backend.native.NativeWindow);

        // Step 2: Reach into the C++ class and pull out the window pointer.
        var sdlWindowPtr: cpp.Star<SDLWindow> = untyped __cpp__(
            "static_cast<lime::SDLWindow*>({0}->__GetHandle())->sdlWindow",
            nativeWindow.handle
        );
        return sdlWindowPtr;
    }

    /**
        Get a pointer to the SDL OpenGL context used internally by Lime.
        
        This function will throw an exception if the window is not backed by
        SDL, such as on Adobe AIR, Flash, and HTML5.
    **/
    private static function getSDLGLContext():cpp.Star<cpp.Void>
    {
        // Step 1: Dig through Lime to get the NativeWindow.
        var window = FlxG.stage.application.window;
        var windowBackend = @:privateAccess window.__backend;
        var nativeWindow = cast(windowBackend, lime._internal.backend.native.NativeWindow);

        // Step 2: Reach into the C++ class and pull out the window pointer.
        var sdlGLContext: cpp.Star<cpp.Void> = untyped __cpp__(
            "static_cast<lime::SDLWindow*>({0}->__GetHandle())->context",
            nativeWindow.handle
        );
        return sdlGLContext;
    }
}

/**
    An OpenFL sprite responsible for rendering ImGui.
**/
class ImGuiSprite extends Sprite
{
    public function new()
    {
        super();
        addEventListener(RenderEvent.RENDER_OPENGL, onRenderOpenGL);
    }

    private function onRenderOpenGL(renderEvent:RenderEvent)
    {
        ImGui_ImplOpenGL3.renderDrawData(ImGui.getDrawData());
    }
}
#end
