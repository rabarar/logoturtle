(* Uncomment the following for Cairo graphics *)
(*
open Cairo
type turtlecontext = { mutable cr: Cairo.context; }

let stroke ctx = Cairo.stroke ctx.cr
let set_source_rgb ctx = Cairo.set_source_rgb ctx.cr
let move_to ctx = Cairo.move_to ctx.cr
let line_to ctx = Cairo.line_to ctx.cr
let set_line_width ctx = Cairo.set_line_width ctx.cr
let create_context w h = let surface = Cairo.Image.create Cairo.Image.ARGB32 w h in
                         let ctx = Cairo.create surface in
                         let wf = (float_of_int w) in
                         let hf = (float_of_int h) in
                         (* paint background white *)
                         Cairo.rectangle ctx 0.0 0.0 wf hf;
                         Cairo.set_source_rgb ctx 1.0 1.0 1.0;
                         Cairo.fill ctx;

                         (* setup turtle coordinates *)
                         Cairo.translate ctx (wf /. 2.0) (hf /. 2.0);
                         Cairo.scale ctx 2. 2.;

                         (* setup turtle line properties *)
                         Cairo.set_line_width ctx 1.0;
                         Cairo.set_source_rgb ctx 0. 0. 0.;
                         Cairo.set_line_join ctx JOIN_MITER;
                         Cairo.set_line_cap ctx SQUARE;
                         Cairo.move_to ctx 0. 0.;
                         { cr = ctx; }

let write_out ctx filename = let surface = Cairo.get_target ctx.cr in
                             Cairo.stroke ctx.cr;
                             Cairo.PNG.write surface filename

*)

open Lwt
open Js
module Html = Dom_html

let error f = Printf.ksprintf (fun s -> Firebug.console##error (Js.string s); failwith s) f

type turtlecontext = { mutable cr : Html.canvasElement Js.t;
                       mutable ctx : Html.canvasRenderingContext2D Js.t;
                       mutable backup: Html.imageData Js.t;
                       mutable saved: bool;
                       mutable w : float;
                       mutable h : float}

let document = Html.window##document


let stroke c  = print_endline "stroke";
                c.ctx##stroke ()
let move_to c x y = print_endline ("moveTo " ^ (string_of_float x) ^ " " ^ (string_of_float y));
                    c.ctx##moveTo (x, y)
let line_to c x y = print_endline ("lineTo " ^ (string_of_float x) ^ " " ^ (string_of_float y));
                    c.ctx##lineTo (x, y)
let set_line_width ctx x = print_endline ("NOT IMPLEMENTED: set_line_width " ^ (string_of_float x))
let set_source_rgb ctx r g b = print_endline ("NOT IMPLEMENTED: set_source_rgb " ^
                                                (string_of_float r) ^ " " ^
                                                (string_of_float g) ^ " " ^
                                                (string_of_float b))
let write_out c filename = stroke c;
                           print_endline ("NOT IMPLEMENTED: write_out " ^ filename )

let draw_turtle c x y h =
  let wf = c.w in
  let hf = c.h in
  let img = Opt.get
              (Opt.bind (document##getElementById (Js.string "turtleimg"))
                        Html.CoerceTo.img)
              (fun () -> error "can't find img element turtleimg") in
  stroke c;
  (* save to backup canvas *)
  c.backup <- c.ctx##getImageData (0., 0., wf, hf);
  c.saved <- true;

  (* draw turtle *)
  c.ctx##save ();
  c.ctx##translate ( x, y);
  c.ctx##rotate (h);
  c.ctx##drawImage_withSize (img, -25., -50. , 50., 50.);
  c.ctx##restore ()

let remove_turtle c = let saved = c.saved in
                      if saved then
                        (c.ctx##putImageData (c.backup, 0., 0.);
                         c.saved <- false;)

let create_context w h = let c = Html.createCanvas document in
                         c##width <- w;
                         c##height <- h;
                         let ctx = c##getContext (Html._2d_) in
                         let wf = float_of_int w in
                         let hf = float_of_int h in
                         ctx##translate (wf /. 2.0 +. 0.5, hf /. 2.0 +. 0.5);
                         ctx##beginPath ();
                         ctx##moveTo (0., 0.);
                         { cr = c;  ctx = ctx; backup = ctx##getImageData (0., 0., wf, hf); saved = false; w = wf; h = hf;}