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
    Context, HasContext, ARRAY_BUFFER, COLOR_BUFFER_BIT, ELEMENT_ARRAY_BUFFER, FLOAT,
    FRAGMENT_SHADER, LINEAR, LINEAR_MIPMAP_NEAREST, MIRRORED_REPEAT, STATIC_DRAW, TEXTURE_2D,
    TEXTURE_2D_ARRAY, TEXTURE_MAG_FILTER, TEXTURE_MIN_FILTER, TEXTURE_WRAP_S, TEXTURE_WRAP_T,
    TRIANGLES, UNSIGNED_INT, VERTEX_SHADER,
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
            let _ = self.triangle();
            self.surface.swap_buffers(&self.context).unwrap_unchecked();
        }
    }

    fn triangle(&self) -> Result<(), Box<dyn Error>> {
        let vertices: [f32; 18] = [
            // positions         // colors
            0.5, -0.5, 0.0, 1.0, 0.0, 0.0, // bottom right
            -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, // bottom let
            0.0, 0.5, 0.0, 0.0, 0.0, 1.0, // top
        ];

        let indice: [u32; 3] = [0, 1, 2];

        let texture_coordinate: [f32; 6] = [
            0.0, 0.0, // lower-let corner
            1.0, 0.0, // lower-right corner
            0.5, 1.0, // top-center corner
        ];

        let indice: Vec<u8> = indice
            .into_iter()
            .flat_map(|byte| byte.to_ne_bytes())
            .collect();

        let vertices: Vec<u8> = vertices
            .into_iter()
            .flat_map(|vertex| vertex.to_ne_bytes())
            .collect();

        unsafe {
            //create vao
            let vao = self.lib.create_vertex_array()?;

            self.lib.bind_vertex_array(Some(vao));

            //texture wrapping
            self.lib
                .tex_parameter_i32(TEXTURE_2D, TEXTURE_WRAP_S, MIRRORED_REPEAT as i32);

            self.lib
                .tex_parameter_i32(TEXTURE_2D, TEXTURE_WRAP_T, MIRRORED_REPEAT as i32);
            //texture mipmap
            // self.lib.generate_mipmap();
            //texture filtering
            self.lib.tex_parameter_i32(
                TEXTURE_2D,
                TEXTURE_MIN_FILTER,
                LINEAR_MIPMAP_NEAREST as i32,
            );

            self.lib
                .tex_parameter_i32(TEXTURE_2D, TEXTURE_MAG_FILTER, LINEAR as i32);

            //create ebo
            let ebo = self.lib.create_buffer()?;
            self.lib.bind_buffer(ELEMENT_ARRAY_BUFFER, Some(ebo));
            self.lib
                .buffer_data_u8_slice(ELEMENT_ARRAY_BUFFER, &indice, STATIC_DRAW);

            //create vbo
            let vbo = self.lib.create_buffer()?;
            self.lib.bind_buffer(ARRAY_BUFFER, Some(vbo));

            self.lib
                .buffer_data_u8_slice(ARRAY_BUFFER, &vertices, STATIC_DRAW);

            //bind 2 vertex_attrib
            let position: u32 = 0;
            let vertex_attributes: i32 = 3;
            let normalized: bool = false;
            let stride: usize = 6 * std::mem::size_of::<f32>();
            let offset: i32 = 0;
            self.lib.vertex_attrib_pointer_f32(
                position,
                vertex_attributes,
                FLOAT,
                normalized,
                stride as i32,
                offset,
            );
            self.lib.enable_vertex_attrib_array(0);

            let position: u32 = 1;
            let vertex_attributes: i32 = 3;
            let normalized: bool = false;
            let stride: usize = 6 * std::mem::size_of::<f32>();
            let offset: i32 = 3 * std::mem::size_of::<f32>() as i32;
            self.lib.vertex_attrib_pointer_f32(
                position,
                vertex_attributes,
                FLOAT,
                normalized,
                stride as i32,
                offset,
            );

            self.lib.enable_vertex_attrib_array(1);

            //shader file
            let shader_file = std::fs::read_to_string("assets/shaders/shader.vert")?;
            let vertex_shader = self.lib.create_shader(VERTEX_SHADER)?;
            self.lib.shader_source(vertex_shader, &shader_file);
            self.lib.compile_shader(vertex_shader);

            let shader_file = std::fs::read_to_string("assets/shaders/shader.frag")?;
            let fragment_shader = self.lib.create_shader(FRAGMENT_SHADER)?;
            self.lib.shader_source(fragment_shader, &shader_file);
            self.lib.compile_shader(fragment_shader);

            //shader_program
            let shader_program = self.lib.create_program()?;
            self.lib.attach_shader(shader_program, vertex_shader);
            self.lib.attach_shader(shader_program, fragment_shader);
            self.lib.link_program(shader_program);

            let color_vertex = self.lib.get_uniform_location(shader_program, "ourColor");

            self.lib.use_program(Some(shader_program));

            self.lib
                .uniform_4_f32(color_vertex.as_ref(), 0.2, 0.5, 0.5, 1.0);
            self.lib.delete_shader(vertex_shader);
            self.lib.delete_shader(fragment_shader);

            self.lib.draw_elements(TRIANGLES, 3, UNSIGNED_INT, 0);
        }

        Ok(())
    }
}
