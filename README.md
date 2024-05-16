# Snake-Simulation

Name: Alexander Dergach & David Davitashvili

Student Number: C20401562 & C20406272

Class Group: TU856, Game Engines 2

Video :


# Description of the project

A simulation of a snake traversing a forest and stone-like environment, avoiding obstacles and the water.
It has snake-like movements, and it wanders until it spots a mouse and will lunge at the mouse and eat it.
You are able to change the parameters of the snake with specific sliders.
There is altitude noise if the camera goes too high, and the closer you get to the snake you can hear it.

# Instructions for use

Run on Godot 4.2.2.stable.mono (The .NET version). Press F5 to run root scene

## In-Game Controls

- All controls will also be viewable in the UI

Base controls for the camera :
> [W A S D]

> [Shift] For speed and Camera FOV change

> [Control] For Camera to decrease elevation

> [Esc] To leave the simulation

> [Space] If Flying : Elevation if flying. If Not Flying: Jump on ground and double press for flight

> [V] Visability of the UI

> [F] Fullscreen toggle

# How it works

## Snake

### Behaviours
The snake has three steering behaviours and two states: avoidance behaviour, harmonic behaviour, seek behaviour, wander state, and attack state. The state machine will initialise the wander state at game start, which adopts the avoidance, harmonic, and seek behaviours all at once. The avoidance detects and avoids obstacles, the harmonic allows the snake to move in a slithering style of movement, and the seek behaviour and go to a destination point. Once the snake detects a mouse in its vicinity, it will change its state to the attack state.  
The attack state adopts all the behaviours as well up until it closly reaches the mouse, which will quickly lunge at the mouse with a chance of missing depending on its own orientation. When the snake successfully attacks the mouse, the mouse will die and the snake will return to the wander state.

#### Wander State
```
# ..within _think function
if random_loc == null:
    random_loc = get_random_point_in_radius()
else:
    snake.get_node("Behaviour_Seek").world_target = random_loc
    
    if snake.get_node("Behaviour_Avoidance").calculate().length() > snake.get_node("Behaviour_Seek").calculate().length()/2:
        var avoidance_force = snake.get_node("Behaviour_Avoidance").calculate()
        var opposite_direction = -avoidance_force.normalized()
        random_loc = snake.global_position + -opposite_direction * radius/2
        random_loc = put_on_ground(random_loc)
        snake.get_node("Behaviour_Seek").world_target = random_loc
        collision_lock = true
    
    if random_loc.distance_to(snake.global_position) < 3:
        random_loc = null
        collision_lock = false
        timer.stop()
        timer.start()
```
If `random_loc` is null, a new random target location within a defined radius is generated using `get_random_point_in_radius()`. If `random_loc` is not null, it sets the snake's seek behavior target to this location. It then checks if the avoidance force (calculated by `Behaviour_Avoidance`) is greater than half of the seek force. If so, it recalculates random_loc to a position in the opposite direction of the avoidance force, adjusts it to be on the ground using `put_on_ground()`, and updates the seek behavior target. If the snake gets within 3 units of `random_loc`, it resets `random_loc` to null, unlocks collision, stops the timer, and restarts it to trigger another target calculation after a delay.  
<br>
<br>
```
func get_random_point_in_radius():
	# choose a random angle within the field of view
	var half_fov = field_of_view_angle / 2
	var random_angle = randf_range(-half_fov, half_fov)
	
	# calculate the direction vector
	var forward_direction = snake.transform.basis.z.normalized()
	var rotation = Quaternion(Vector3.UP, random_angle)
	var direction = rotation*forward_direction
	
	# calculate the random point within the radius
	var x = direction.x * radius * randf()
	var z = direction.z * radius * randf()

	var targetloc = snake.global_position + Vector3(x, 0, z)
	
	var pos_on_ground = put_on_ground(targetloc)
	
	return pos_on_ground
```
The `get_random_point_in_radius` function generates a random point within a specified radius around the snake, ensuring the point is within the snake's forward-facing field of view. It first calculates a random angle within half the field of view, then creates a direction vector based on this angle. Using this direction, it computes random x and z coordinates within the given radius, forming a target location. This target location is then adjusted to ensure it lies on the ground using the `put_on_ground` function, and the final adjusted location is returned.  
<br>
<br>
```
func put_on_ground(loc):
	var raycast = RayCast3D.new()
	raycast.target_position = Vector3(0, -50, 0)
	raycast.global_position = loc + Vector3(0, 50, 0)
	
	add_child(raycast)
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		loc.y = raycast.get_collision_point().y
	
	remove_child(raycast)
	raycast.queue_free()
	
	return loc
```
The `put_on_ground` function adjusts a given location to ensure it is on the ground by using a `RayCast3D`. It creates a new `RayCast3D` instance, sets its target position to cast 50 units downward from 50 units above the given location, and adds it to the scene. The raycast is forced to update immediately, and if it detects a collision with the ground, it adjusts the y-coordinate of the given location to match the collision point's y-coordinate. Finally, the raycast is removed from the scene and freed from memory, and the adjusted location is returned.  
<br>
<br>
```
# ..within _think function
    if !prey:
        detect_prey()
    else:
        snake.prey = prey
        var AttackState = load("res://Scripts/State_Attack.gd")
        snake.get_node("StateMachine").change_state(AttackState.new())

func detect_prey():
	for p in snake.prey_list:
		if is_instance_valid(p):
			if p.global_position.distance_to(snake.global_position) < radius:
				prey = p
				break
```
Within the `_think` function, the code checks if there is no detected prey. If no prey is detected, it calls `detect_prey()`, which iterates through a list of potential prey objects (`prey_list`). For each valid prey object, it checks if the prey is within a specified radius from the snake's position. If a prey is found within this radius, it sets the `prey` variable to this object and breaks out of the loop. If prey is detected, the snake's prey is set to the detected prey, and the state of the snake is changed to `State_Attack` by loading and transitioning to the attack state script.  

#### Attack State
```
func _think():
	if prey.global_position.distance_to(snake.global_position) < 10:
		if snake.get_node("Behaviour_Harmonic").is_enabled():
			snake.get_node("Behaviour_Harmonic").set_enabled(false)
			snake.get_node("Behaviour_Avoidance").set_enabled(false)
		
		snake.get_node("Behaviour_Seek").world_target = prey.global_position
		snake.get_node("Behaviour_Seek").set_enabled(true)
		snake.max_speed = 50
		snake.speed = 50
		snake.damping = -5
		
		if prey.global_position.distance_to(snake.global_position) < 3:
			attack_sound.play()
			mouse_sound.play()
			blood_particle.restart()
			
			prey.queue_free()
			snake.prey_list.erase(prey)
			
			var WanderState = load("res://Scripts/State_Wander.gd")
			snake.get_node("StateMachine").change_state(WanderState.new())
			
	snake.get_node("Behaviour_Seek").world_target = prey.global_position
```
In the Attack State, the `_think` function controls the snake's behavior when it detects prey. If the prey is within 10 units of the snake, it disables the `Behaviour_Harmonic` and `Behaviour_Avoidance` behaviors to stop the snake's harmonic movement and avoidance. It then sets the snake's seek target to the prey's position, enabling the `Behaviour_Seek` behavior and increasing the snake's speed and reducing its damping to make it move faster towards the prey. If the prey gets within 3 units of the snake, the function plays attack and mouse sounds, restarts the blood particle effect, removes the prey from the scene and the snake's prey list, and transitions the snake back to the `State_Wander` state by loading and switching to the wander state script. The seek target is continuously updated to the prey's position.


### UI
The UI allows the player to tweak four values in game: max speed, slither radius, slither amplitude and seek radius. The max speed slider changes the overall speed of the snake. The slither radius changes how wide the slithering is performed. The slither amplitude determines how the amplitude of the slithering. Lastly, the seek radius determines how far the snake's seek behaviour will get a random position in the wander state.
![image](https://github.com/AlexDergach/Snake-Simulation/assets/98461460/7cd874e1-a5ec-46c7-be28-bbc0ea31ee5f)


## Sound
The sound is a mixture of free online sources and self-made sounds. For example, the sound of the snake is us hissing into the mic and adding sound effects to it.

- Snake :
Is a 3D sound node that gets louder the closer you get to the head of the snake, and it has an attack sound that plays once it attacks a mouse.
- Mouse :
Custom sound for the mouse once the snake eats it
- Air :
This sound gets louder as your 'Altitude elvates' and only starts playing at a certain Y level of the camera.
- Nature :
This is a mixture of sounds that play through out the whole simulation: nature and river sounds when you get closer to the water.

## Map

The map is made up of a number of different assets, and the terrian is a C# plugin. The assets are bunched into an array with different frequencies to spread them out and have different asset values. 
There is a day and night cycle with an animation player controlling the colour of the world environment, rotation, and light levels of the directional light.
There are mountainous regions, sandy beaches, and a rocky dune, letting the snake traverse a number of terrains.

Night Example:
![image](https://github.com/AlexDergach/Snake-Simulation/assets/98461460/61e8ac2c-1402-4ce4-a1ec-af8dcfa7a8a9)


## Map

Map is made up of a number of different assets and the terrian is a 

## Post Processing

We enabled a post processing function that you can toggle for a different experince when obeserving the simulation.
Pressing P you can switch camera states of visibility

The shader is implemented as a spatial shader with an unshaded render mode, allowing for efficient processing of each fragment. It utilizes uniform variables for edge threshold, saturation strength, and contrast strength, enabling dynamic adjustments to the visual effect.

It has a technique for edge detection by sampling depth and normal textures. By calculating differences in depth and normal values in both horizontal and vertical directions
Color processing begins with the conversion of color values to a linear color space to ensure accurate adjustments. Saturation is enhanced by preserving luminance while intensifying color values, and contrast is increased by manipulating color values around a midpoint.

```

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    
    // Sample depth and normal textures
    float depth = texture(depth_texture, SCREEN_UV).r;
    vec3 normal = texture(normal_texture, SCREEN_UV).rgb;

    // Calculate edge strength
    float depth_diff_x = abs(depth - texture(depth_texture, SCREEN_UV + vec2(0.001, 0)).r);
    float depth_diff_y = abs(depth - texture(depth_texture, SCREEN_UV + vec2(0, 0.001)).r);
    float depth_edge = smoothstep(0.0, edge_threshold, depth_diff_x + depth_diff_y);

    vec3 normal_diff_x = abs(normal - texture(normal_texture, SCREEN_UV + vec2(0.001, 0)).rgb);
    vec3 normal_diff_y = abs(normal - texture(normal_texture, SCREEN_UV + vec2(0, 0.001)).rgb);
    float normal_edge = smoothstep(0.0, edge_threshold, length(normal_diff_x + normal_diff_y));

    // Combine edge strengths
    float edge = max(depth_edge, normal_edge);
    
    // Convert to linear color space
    vec3 linear_color = color.rgb / max(color.a, 0.0001);  // Avoid division by zero
    
    // Apply saturation
    vec3 gray = vec3(dot(vec3(0.2126, 0.7152, 0.0722), linear_color));
    vec3 saturated_color = mix(gray, linear_color, saturation_strength);
    
    // Apply contrast
    vec3 contrasted_color = (saturated_color - 0.55) * contrast_strength + 0.5;
    
    // Mix original color with edge-enhanced color based on edge strength
    vec3 final_color = mix(contrasted_color, linear_color, edge);
    
    // Output the final color
    ALBEDO = vec3(final_color);
}
```

Having the vertex ensure the whole screen is encompassed

```
void vertex() {
    POSITION = vec4(VERTEX, 1.0);
}
```

## Particles

Particles were implemented for both the snakes movements and the blood splatter of the mouse once it was eaten, creating an ont-shot splashing effect.
Firefly parts were set up with a slight transparency for the environment, so with the day and night cycles bringing night to give the terrian a better nighttime atmosphere of glowling sparks of green

[David add a little some of the code you added for particals of the snake and mouse]

# List of classes/assets in the project

| Class/Asset | Source |
|-----------|-----------|
| JerseyFont | Refernce1 |
| Background1 | Refernce2 |
| Background2 | Refernce3 |
| River | Refernce4 |
| Attack Sound | Self Made |
| Mouse Death Sound | Self Made |
| Air | Self Made |
| Snake | Self Made |
| Foliage | Refernce5 |
| Map Models | Refernce6 |
| Snake_body.glb | Self Made |
| Snake_head.glb | Self Made |
| Snake_pieces.blend| Self Made |
| Snake_tailpiece.glb | Self Made |
| Map.tscn  | Self Made with refernces |
| BloodParticals.tscn  | Self Written |
| GroundParticals.tscn  | Self Written |
| FireFlyParticals.tscn  | Self Written |
| Camera.gdshader | Self Written |
| Map Grass Texture | Refernce7 |
| Map Rock Texture | Refernce8 |
| Map RockGrass Texture | Refernce9 |
| Map RockSand Texture | Refernce10 |
| Map Sand Texture | Refernce11 |
| Snake Texture | Self Drawn |
| Terra Brush | Plugin |

# References

| Ref No. | Name | Source |
|-----------|-----------|-----------|
| 1 | Jersey15-Regular.ttf | https://fonts.google.com/download/next-steps |
| 2 | background.mp3 | https://www.chosic.com/download-audio/27947/ |
| 3 | background2.mp3| https://www.chosic.com/download-audio/27947/ |
| 4 | river.mp3 | https://www.chosic.com/download-audio/27947/ |
| 5 | sprite_0001.png | https://kenney.nl/assets/foliage-sprites |
| 6 | [Array Of Models].glb | https://kenney.nl/assets/foliage-sprites |
| 7 | Grass001.png | https://ambientcg.com/list?category=&date=&createdUsing=&basedOn=&q=&method=&type=Material&sort=Popular |
| 8 | Rock050.png | https://ambientcg.com/list?category=&date=&createdUsing=&basedOn=&q=&method=&type=Material&sort=Popular |
| 9 | Rock051.png | https://ambientcg.com/list?category=&date=&createdUsing=&basedOn=&q=&method=&type=Material&sort=Popular |
| 10 | Ground067.png | https://ambientcg.com/list?category=&date=&createdUsing=&basedOn=&q=&method=&type=Material&sort=Popular |
| 11 | Ground054.png | https://ambientcg.com/list?category=&date=&createdUsing=&basedOn=&q=&method=&type=Material&sort=Popular |

# What I am most proud of in the assignment

- We are proud of snake item 1
- We are proud of snake item 2
- We are proud of the custom sound design and atmosphere
- We are proud of the partical designs
- We are proud of the dynamically changing UI
- We are proud of the mouse item 1
- We are proud of how the camera works
- We are proud we could mimic a cool lookin snake :D

# What I learned

- We learnt how snake item 1
- We learnt how snake item 2
- We learnt how snake item 3
- We learnt how mouse item 1
- We learnt about path finding and navigation
- We learnt about godot's lighting and shadow system for maps
- We learnt how challenging it can be to combine models and interact game systems and design
- We learnt how you can edit sound pitch and other effects

## Prior Snake Research

Having a close friend who supplies pet stores and zoos with a variety of different animals, we were able to learn firsthand how to handle the snakes.
We modelled the snake according to what we saw, and the textures matched the skin tone. 
We found that the snakes initially eat mice, so we added a mouse as its food source within the simulation.
It was a very interesting experience to be able to bring what we saw in the real world into a virtual world.

![Screenshot 2024-05-16 153250](https://github.com/AlexDergach/Snake-Simulation/assets/78319537/148d8834-847a-460c-b231-62ea487caf12)
![Screenshot 2024-05-16 153218](https://github.com/AlexDergach/Snake-Simulation/assets/78319537/f268b21c-d2b5-4161-a227-0f809d86b355)
![Screenshot 2024-05-16 153241](https://github.com/AlexDergach/Snake-Simulation/assets/78319537/f4f89aab-446c-444f-b21b-db8c41f61e56)

https://github.com/AlexDergach/Snake-Simulation/assets/78319537/83370b97-98ca-4dda-a1b0-4d35b2394c2d

https://github.com/AlexDergach/Snake-Simulation/assets/78319537/09607bde-cfaa-4565-be2b-f797bd4135a3


  
