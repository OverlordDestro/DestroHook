shader_type spatial;
render_mode cull_disabled;
/** how frequently the rope should go up and down*/
uniform float frequency = 1; 
/** how high or low the peaks should be*/
uniform float maxAmplitude = 0.25;
/** how fast it's swinging */
uniform float speed = 10;
/** 1 to enable, 0 to disable the shader*/
uniform float active : hint_range(0.0, 1.0, 1.0);
void vertex() {
    // Scale the amplitude based on the position (more at the beginning, less at the end)
	if(active == 1.0)
	{
	    //float scaledAmplitude = maxAmplitude * (VERTEX.y -.06 ); //use this piece of code if you want the shader to work on the entire rope instead of only half of it
		float scaledAmplitude = maxAmplitude * (1.0 - clamp(VERTEX.y, 0.0, 1.0)); 
	    // Calculate the sine wave for the wiggle
	    float wave = scaledAmplitude * sin(VERTEX.y * frequency + TIME * speed);
		VERTEX.z += wave;
	}
}
void fragment() {

	ALBEDO = vec3(0,0,0);
}