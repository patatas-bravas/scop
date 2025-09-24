use winit::event_loop::{ControlFlow, EventLoop};

mod scop;
use scop::Scop;

fn main() {
    let event_loop = EventLoop::new().expect("ERROR: 1");

    event_loop.set_control_flow(ControlFlow::Poll);

    let mut scop = Scop::new();

    match event_loop.run_app(&mut scop) {
        Ok(_) => println!("OK"),
        Err(err) => println!("ERROR: {err}"),
    }
}
