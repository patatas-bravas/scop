use std::error::Error;
use std::num::NonZero;

use glutin::config::ConfigTemplateBuilder;
use glutin::context::{ContextApi, ContextAttributesBuilder, PossiblyCurrentContext, Version};
use glutin::display::GetGlDisplay;
use glutin::prelude::{GlDisplay, NotCurrentGlContext};
use glutin::surface::{GlSurface, Surface, SurfaceAttributesBuilder, WindowSurface};
use glutin_winit::{ApiPreference, DisplayBuilder};

use winit::event_loop::ActiveEventLoop;
use winit::raw_window_handle::HasWindowHandle;
use winit::window::Window;

use glow::{
    Context, HasContext, ARRAY_BUFFER, COLOR_BUFFER_BIT, FLOAT, FRAGMENT_SHADER, STATIC_DRAW,
    TRIANGLES, VERTEX_SHADER,
};

pub struct OpenGL {
    surface: Surface<WindowSurface>,
    context: PossiblyCurrentContext,
    lib: Context,
}

impl OpenGL {
    pub fn new(window: &Window, event_loop: &ActiveEventLoop) -> Result<Self, Box<dyn Error>> {
        let raw_window_handle = window.window_handle()?.as_raw();

        let template = ConfigTemplateBuilder::new();

        let display = DisplayBuilder::new().with_preference(ApiPreference::FallbackEgl);

        let config = display
            .build(event_loop, template, |mut configs| {
                configs.next().expect("ERROR: 3")
            })?
            .1;

        let context_attributes = ContextAttributesBuilder::new()
            .with_context_api(ContextApi::OpenGl(Some(Version::new(4, 6))))
            .with_debug(false)
            .build(Some(raw_window_handle));

        let (width, height): (u32, u32) = window.inner_size().into();

        let surface_attributes = SurfaceAttributesBuilder::<WindowSurface>::new().build(
            raw_window_handle,
            NonZero::new(width.max(1)).expect("ERROR: IMPOSSIBLE"),
            NonZero::new(height.max(1)).expect("ERROR: IMPOSSIBLE"),
        );

        let surface = unsafe {
            config
                .display()
                .create_window_surface(&config, &surface_attributes)?
        };

        let context = unsafe {
            config
                .display()
                .create_context(&config, &context_attributes)?
                .make_current(&surface)?
        };

        let lib = unsafe {
            glow::Context::from_loader_function(|addr| {
                let addr = std::ffi::CString::new(addr).expect("ERROR: 4");
                config.display().get_proc_address(&addr)
            })
        };

        Ok(Self {
            surface,
            context,
            lib,
        })
    }

    pub fn draw(&self) {
        unsafe {
            self.lib.clear_color(1.0, 1.0, 1.0, 1.0);
            self.lib.clear(COLOR_BUFFER_BIT);
        }

        self.surface.swap_buffers(&self.context).unwrap();
    }

    fn triangle(&self) -> Result<(), Box<dyn Error>> {
        let vertices: [f32; 9] = [-0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.0, 0.5, 0.0];

        let data: Vec<u8> = vertices
            .into_iter()
            .flat_map(|vertex| vertex.to_ne_bytes())
            .collect();

        unsafe {
            let vao = self.lib.create_vertex_array()?;

            let vbo = self.lib.create_buffer()?;

            self.lib.bind_buffer(ARRAY_BUFFER, Some(vbo));

            self.lib
                .buffer_data_u8_slice(ARRAY_BUFFER, &data, STATIC_DRAW);

            let vertex_shader = self.lib.create_shader(VERTEX_SHADER)?;

            let shader_file = std::fs::read_to_string("shaders/shader.vert")?;

            self.lib.shader_source(vertex_shader, &shader_file);

            self.lib.compile_shader(vertex_shader);

            let fragmet_shader = self.lib.create_shader(FRAGMENT_SHADER)?;

            let shader_file = std::fs::read_to_string("shaders/shader.frag")?;

            self.lib.shader_source(fragmet_shader, &shader_file);

            self.lib.compile_shader(fragmet_shader);

            let shader_program = self.lib.create_program()?;

            self.lib.attach_shader(shader_program, vertex_shader);
            self.lib.attach_shader(shader_program, fragmet_shader);

            self.lib.link_program(shader_program);

            self.lib.use_program(Some(shader_program));

            self.lib.delete_shader(vertex_shader);
            self.lib.delete_shader(fragmet_shader);

            self.lib.vertex_attrib_pointer_f32(
                0,
                3,
                FLOAT,
                false,
                3 * std::mem::size_of::<f32>() as i32,
                0,
            );

            self.lib.enable_vertex_attrib_array(0);

            self.lib.bind_vertex_array(Some(vao));

            self.lib.draw_arrays(TRIANGLES, 0, 3);
        }

        Ok(())
    }
}
