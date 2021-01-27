switch (ReactDOM.querySelector("#root")) {
| Some(root) => ReactDOM.render(<SwitchViewer />, root)
| None => ()
};
