use winit::{
    application::ApplicationHandler,
    event::WindowEvent,
    event_loop::ActiveEventLoop,
    window::{Window, WindowAttributes, WindowId},
};

mod opengl;
use opengl::OpenGL;

#[derive(Default)]
pub struct Scop {
    window: Option<Window>,
    opengl: Option<OpenGL>,
}

impl Scop {
    pub fn new() -> Self {
        Scop::default()
    }
}

impl ApplicationHandler for Scop {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.window.is_none() {
            let window = event_loop
                .create_window(WindowAttributes::default())
                .expect("ERROR: 5");

            let opengl = OpenGL::new(&window, &event_loop).expect("ERROR: 6");

            self.window = Some(window);
            self.opengl = Some(opengl);
        }
    }

    fn window_event(&mut self, event_loop: &ActiveEventLoop, _: WindowId, event: WindowEvent) {
        match event {
            WindowEvent::RedrawRequested => self.opengl.as_ref().unwrap().draw(),

            WindowEvent::CloseRequested => event_loop.exit(),

            _ => {}
        }
    }
}
