function HitAnimationController(): FigureAnimationController() constructor{
	anim_type = "hit";
	start_xscale = figure_xscale;
	start_yscale = figure_yscale;
	
	animate = function() {
		if animation_frame < animation_length/2.1 and figure_xscale < start_xscale + 0.025*8 {
			figure_xscale += 0.0025;
			figure_yscale += 0.0025;
			figure_alpha -= 0.04
		}
		else if animation_frame > animation_length/1.4 and figure_xscale > start_xscale {
			figure_xscale -= 0.006;
			figure_yscale -= 0.006
			figure_alpha += 0.08
		}
		if animation_frame >= (animation_length-1) {
			figure_xscale = start_xscale;
			figure_yscale = start_yscale;
			fgure_alpha = 1;
		}
	}
}