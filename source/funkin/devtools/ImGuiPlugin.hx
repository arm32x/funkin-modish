package funkin.devtools;

#if (MODISH_DEV && cpp)
import flixel.FlxBasic;
import flixel.FlxG;
import imguicpp.ImGui;
import openfl.display.Sprite;
import openfl.events.RenderEvent;

@:native("SDL_Window")
extern class SDL_Window {}
typedef SDL_GLContext = cpp.Star<cpp.Void>;

// Bindings to ImGui backends. Note that imgui-hx must be used at least once
// in the file for the include paths to resolve.
@:include("imgui_impl_sdl.h")
extern class ImGui_ImplSDL2
{
    @:native("ImGui_ImplSDL2_InitForOpenGL")
    static function initForOpenGL(window:cpp.Star<SDL_Window>, glContext:SDL_GLContext):Bool;

    @:native("ImGui_ImplSDL2_Shutdown")
    static function shutdown():Void;
    
    @:native("ImGui_ImplSDL2_NewFrame")
    static function newFrame():Void;
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

// Add SDL's header files to the include path. This is necessary since SDL
// types and functions are used in this file.
//
// This requires the haxelib linc_sdl to be installed.
@:buildXml("
<files id='haxe' append='true'>
    <compilerflag value='-I${haxelib:linc_sdl}/lib/sdl/include/' />

    <compilerflag value='-I${haxelib:linc_sdl}/lib/sdl/include/configs/default/'    unless='windows || mac || linux'/>
    <compilerflag value='-I${haxelib:linc_sdl}/lib/sdl/include/configs/linux/'      if='linux'/>
    <compilerflag value='-I${haxelib:linc_sdl}/lib/sdl/include/configs/windows/'    if='windows'/>
    <compilerflag value='-I${haxelib:linc_sdl}/lib/sdl/include/configs/mac/'        if='mac'/>
</files>
")

// This code is a slightly modified version of Lime's internal Window and
// SDLWindow class definitions. It is here because the header these classes are
// from is not accessible to this project.
//
// See original source code here:
// https://github.com/native-toolkit/lime/blob/develop/project/src/backend/sdl/SDLWindow.h
@:headerCode("
#define SDL_MAIN_HANDLED 1
#include <imgui_impl_sdl.h>
#include <SDL.h>

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

// SDL event filters can be used to process events before Lime has a chance to.
// This code defines an event filter function in C++ that will allow ImGui to
// process SDL events.
static int SDLCALL imgui_event_filter(void* userdata, SDL_Event* event)
{
    ImGui_ImplSDL2_ProcessEvent(event);
    
    ImGuiIO& io = ImGui::GetIO();
    if (io.WantCaptureMouse
        && (event->type == SDL_MOUSEMOTION
            || event->type == SDL_MOUSEWHEEL
            || event->type == SDL_MOUSEBUTTONDOWN
            || event->type == SDL_MOUSEBUTTONUP)
        || io.WantCaptureKeyboard
        && (event->type == SDL_TEXTINPUT
            || event->type == SDL_KEYDOWN
            || event->type == SDL_KEYUP))
    {
        return 0;
    }
    
    return 1;
}
")
class ImGuiPlugin extends FlxBasic
{
    public function new()
    {
        super();
        
        ImGui.createContext();
        ImGui.styleColorsDark();
        
        var io = ImGui.getIO();
        io.configFlags |= ImGuiConfigFlags.NavEnableKeyboard;
        io.configFlags |= ImGuiConfigFlags.DockingEnable;
        #if MODISH_IMGUI_VIEWPORTS
        io.configFlags |= ImGuiConfigFlags.ViewportsEnable;
        #end
        
        var sdlWindow = getLimeSDLWindow();
        var sdlGLContext = getLimeSDLGLContext();
        ImGui_ImplSDL2.initForOpenGL(sdlWindow, sdlGLContext);
        ImGui_ImplOpenGL3.init("#version 130");
        
        FlxG.stage.addChild(new ImGuiSprite());
        
        // See @:headerCode metadata above for implementation of
        // imgui_event_filter.
        untyped __cpp__("SDL_SetEventFilter(imgui_event_filter, NULL)");
        
        // Using these pre- and post- update signals allows ImGui to be used
        // anywhere in the game.
        FlxG.signals.preUpdate.add(() -> {
            ImGui_ImplOpenGL3.newFrame();
            ImGui_ImplSDL2.newFrame();
            ImGui.newFrame();
        });
        FlxG.signals.postUpdate.add(() -> {
            ImGui.render();
            
            if ((io.configFlags & ImGuiConfigFlags.ViewportsEnable) != 0) { 
                // These functions can change the current OpenGL context, but
                // Lime always makes its own context current before rendering.
                ImGui.updatePlatformWindows();
                ImGui.renderPlatformWindowsDefault(null, null);
            }
        });
    }
    
    override public function destroy()
    {
        ImGui_ImplOpenGL3.shutdown();
        ImGui_ImplSDL2.shutdown();
        ImGui.destroyContext();

        untyped __cpp__("SDL_SetEventFilter(NULL, NULL)");
    }
    
    /**
        Get a pointer to the SDL window used internally by Lime.
        
        This function will throw an exception if the window is not backed by
        SDL, such as on Adobe AIR, Flash, and HTML5.
    **/
    private static function getLimeSDLWindow():cpp.Star<SDL_Window>
    {
        // Step 1: Dig through Lime to get the NativeWindow.
        var window = FlxG.stage.application.window;
        var windowBackend = @:privateAccess window.__backend;
        var nativeWindow = cast(windowBackend, lime._internal.backend.native.NativeWindow);

        // Step 2: Reach into the C++ class and pull out the window pointer.
        var sdlWindowPtr:cpp.Star<SDL_Window> = untyped __cpp__(
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
    private static function getLimeSDLGLContext():SDL_GLContext
    {
        // Step 1: Dig through Lime to get the NativeWindow.
        var window = FlxG.stage.application.window;
        var windowBackend = @:privateAccess window.__backend;
        var nativeWindow = cast(windowBackend, lime._internal.backend.native.NativeWindow);

        // Step 2: Reach into the C++ class and pull out the window pointer.
        var sdlGLContext:SDL_GLContext = untyped __cpp__(
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
