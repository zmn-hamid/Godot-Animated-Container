# Godot Animated Container

This is a sample project I made to illustrate how responsive container can meet
animations without facing the `transform` limitations made by the container.  
Two methods were used:
1. Via duplication and synchronization -> ui_sync_children:
    - Is more complex
    - Full access to animations: The elements will never reset to the base properties.
    Only the changes are made to the real (actual) children. Any further transformation is persisted.
    Please make sure you read the logic section for further explanation.
    - Can add more logic and turn off / on the synchronization
2. Via `_notification` function -> ui_notif_handler:
    - A more Godot-ish way of handling this
    - Simpler logic
    - No full animation access: when the container changes (e.g. a new node is added or container is resized)
    everything is reset. The only thing that is added to the default behaviour is
    the animation made for the reordering of children
    - Can't turn off the animation for a while

## Showcase (for method 1)

https://github.com/user-attachments/assets/31148fc2-b159-4cad-a0b7-9054aa128e12

## The logic for method 1

This goal is achieved via duplication. There'a `HBoxContainer` called `Responsive`
which holds all the `TextureRect`s as usual, and then there's an empty `Control` node
called `Actual` which will be synced to the `Responsive` node's children and animated.

The syncronization is not absolute, which means, only the changes made to the responsive
children is forced on the actual children. This way any transformation to the actual
children is persisted and only changes are reflected.

#### How tho?

There's a variable called `mapped` which acts like a pointer system. It maps the children of
`responsive` to the children of `actual`.  
There's also another variable called `tracked` which tracks the last properties of the the
responsive children.  
The `start_sync` function checks for the changes made to the responsive children, and reflects
those changes on the equivalent actual children. This way no matter what transformation you did to the
actual children, the responsive children will not reset them, but will affect them accordingly.  
Note: `Responsive` node's `modulate:a` is set to `0.0` so only the actual nodes are shown.  

#### What properties are synced?

To keep the project minimal, only the changes to `global_position` is tracked and synced.
You can modify the `sync_core` function to add other properties such as `scale`.

### How can i animate the actual children? (IMPORTANT)

Everytime you want to manually animate the actual children, make sure the `tween` variable
is not running by doing:

    await tween_finished()
    tween = create_tween()

You should do this because everytime the `child_order_changed` is emitted,
the `tween` handles the defined properties (`global_position` in this project)
and any attempt at animating the same properties at the same time would makes issues.
you should await the `finished` signal and create a new tween to block other attempts.  

If you want to do constant animations (e.g floating), either use shaders or create
a new system that would pause the animation while `tween` is running and play after
it's finished. you can await the tween in the animation loop as well, using the block of
code shown above.

#### How optimized is it?

Syncing only happens once when the tree is made, and once per each change (addition/removal/reorder).
Thank `child_order_changed` signal for that. You can check the code for further info on how
optimized it is -> [ui.gd](ui_sync_children/ui.gd).

<b>In case you want to track the changes to other properties, you have to either find the
corresponding signals or simply run `start_sync` function in each process frame, which would
be less optimized</b>

## The logic for method 2

When the children are sorted, the built-in `_notification` tracks the previous
states and animates the sorting.

## Attribution

ui_sync_children -> corgi120's [post](https://www.reddit.com/r/godot/comments/x00qc4/turn_order_ui_trick_to_animate_children_inside/) on Reddit  
ui_notif_handler -> ArchieVillain's [issue](https://github.com/godotengine/godot-proposals/issues/9616)

# License

This project is licensed under the GNU General Public License (GPL) v3. You are free to use, modify, and distribute it, but any derivative work must also be open source and released under the same license. See [LICENSE](https://www.gnu.org/licenses/gpl-3.0.en.html) for full terms.
