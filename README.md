# Godot Animated Container

This is a sample project I made to illustrate how responsive container can meet
animations without facing the `transform` limitations made by the container.  
Two methods were used:
1. Via `_notification` function -> ui_notif_handler:
    - A more Godot-ish way of handling this
    - Simpler logic
    - No full animation access: when the container changes (e.g. a new node is added or container is resized)
    everything is reset
    - Can't turn off the animation for a while
2. Via duplication and synchronization -> ui_sync_children:
    - Is more complex
    - Full access to animations: The only thing that will reset are the properties
    you define. In this project the global_position is synchronized.
    - Can add more logic and turn off / on the synchronization

## Showcase (for method 2)

https://github.com/user-attachments/assets/31148fc2-b159-4cad-a0b7-9054aa128e12

For the first method, there are less animations but still pretty good

## The Logic for ui sync children

This goal is achieved via duplication. There'a `HBoxContainer` called `Responsive`
which holds all the `TextureRect`s as usual, and then there's an empty `Control` node
called `Actual` which will be synced to the `Responsive` node's children and animated.

You can check the code at [ui.gd](ui_sync_children/ui.gd) in `synchronize_actual` function. 

Note1: `Responsive` node's `modulate:a` is set to `0.0` so only the actual nodes are shown.  
Note2: The only property that is tracked and animated is `position`.

## The Logic for ui notification handler

When the children are sorted, the built-in _notification function handles the animatins

## Attribution

ui_sync_children -> corgi120's [post](https://www.reddit.com/r/godot/comments/x00qc4/turn_order_ui_trick_to_animate_children_inside/) on Reddit  
ui_notif_handler -> ArchieVillain's [issue](https://github.com/godotengine/godot-proposals/issues/9616)
