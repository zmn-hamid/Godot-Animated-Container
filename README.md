# Godot Animated Container

This is a small project I made to illustrate how responsive container can meet
animations without facing the `transform` limitations made by the container.  

Note: The only property that is tracked and animated is `position`.

## The Logic

This goal is achieved via duplication. There'a `HBoxContainer` called `Responsive`
which holds all the `TextureRect`s as usual, and then there's an empty `Control` node
called `Actual` which will be synced to the `Responsive` node's children.

You can check the code at [ui.gd](ui.gd) in `check_for_changes` function. 

## The Use-Case

This way you can easily do any animation you want with the actual nodes, without 
facing the limitations set by `Container`s.
