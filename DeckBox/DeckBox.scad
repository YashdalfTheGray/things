// =============================================================================
// PARAMETERS
// =============================================================================
interior_x = 70.5;
interior_y = 76.5;
interior_z = 95;
wall_thickness = 4;
lid_height = 59.5;
lip_fillet_radius = 1.8;
chamfer_size = 2;
detent_radius = 1;
facets = 32;

animate = true;
animation_height = 50;
pause_start = 0.2;
pause_end = 0.8;

// =============================================================================
// CONSTANTS
// =============================================================================
CHAMFER_TOP_HORIZONTAL_PARALLEL = [45, 0, 0];
CHAMFER_TOP_HORIZONTAL_PERPENDICULAR = [45, 0, 90];
CHAMFER_BOTTOM_HORIZONTAL = [-45, 0, 0];
CHAMFER_VERTICAL = [45, 90, 0];

// =============================================================================
// DERIVED DIMENSIONS
// =============================================================================
lip_wall_thickness = wall_thickness * 0.45;
lid_wall_thickness = wall_thickness * 0.55;

outer_x = interior_x + 2 * wall_thickness;
outer_y = interior_y + 2 * wall_thickness;
outer_z = interior_z + wall_thickness + lid_wall_thickness;

bottom_height = outer_z - lid_height;
lip_height = lid_height - bottom_height;

lid_interior_x = interior_x + 2 * lip_wall_thickness;
lid_interior_y = interior_y + 2 * lip_wall_thickness;
lid_interior_z = lid_height - lid_wall_thickness;

lip_outer_x = lid_interior_x;
lip_outer_y = lid_interior_y;

lip_offset_x = (outer_x - lip_outer_x) / 2;
lip_offset_y = (outer_y - lip_outer_y) / 2;

// =============================================================================
// ANIMATION PARTICULARS
// =============================================================================
function calculate_lid_z_position(t, bottom_height, animation_height, pause_start, pause_end) = 
  t < pause_start ? bottom_height + animation_height :
  t > pause_end ? bottom_height :
  bottom_height + animation_height * (1 - (t - pause_start) / (pause_end - pause_start));

lid_x_position = animate ? 0 : 100;
lid_y_position = animate ? 0 : outer_y;
lid_z_position = animate ?
  calculate_lid_z_position($t, bottom_height, animation_height, pause_start, pause_end):
  lid_height;
lid_x_rotation = animate ? 0 : 180;

// =============================================================================
// HELPER MODULES
// =============================================================================
module rounded_cube(size, radius, fn = facets) {
  hull() {
    translate([radius, radius, 0]) {
      cylinder(r = radius, h = size[2], $fn = fn);
    }
    translate([size[0] - radius, radius, 0]) {
      cylinder(r = radius, h = size[2], $fn = fn);
    }
    translate([radius, size[1] - radius, 0]) {
      cylinder(r = radius, h = size[2], $fn = fn);
    }
    translate([size[0] - radius, size[1] - radius, 0]) {
      cylinder(r = radius, h = size[2], $fn = fn);
    }
  }
}

module chamfer_cutter(length, chamfer_size, rotation = [45, 0, 0]) {
  rotate(rotation) {
    cube([length, chamfer_size * sqrt(2), chamfer_size * sqrt(2)], center = true);
  }
}

// =============================================================================
// GEOMETRY
// =============================================================================
// main box
difference() {
  difference() {
    cube([outer_x, outer_y, bottom_height]);
    translate([wall_thickness, wall_thickness, wall_thickness]) {
      rounded_cube([interior_x, interior_y, interior_z], lip_fillet_radius / 2);
    }
  }
  
  translate([outer_x / 2, 0, 0]) {
    chamfer_cutter(outer_x + 2, chamfer_size, CHAMFER_TOP_HORIZONTAL_PARALLEL);
  }
  translate([outer_x / 2, outer_y, 0]) {
    chamfer_cutter(outer_x + 2, chamfer_size, CHAMFER_TOP_HORIZONTAL_PARALLEL);
  }
  translate([0, outer_y / 2, 0]) {
    chamfer_cutter(outer_y + 2, chamfer_size, CHAMFER_TOP_HORIZONTAL_PERPENDICULAR);
  }
  translate([outer_x, outer_y / 2, 0]) {
    chamfer_cutter(outer_y + 2, chamfer_size, CHAMFER_TOP_HORIZONTAL_PERPENDICULAR);
  }
  
  translate([0, 0, bottom_height / 2]) {
    chamfer_cutter(bottom_height + 2, chamfer_size, CHAMFER_VERTICAL);
  }
  translate([outer_x, 0, bottom_height / 2]) {
    chamfer_cutter(bottom_height + 2, chamfer_size, CHAMFER_VERTICAL);
  }
  translate([0, outer_y, bottom_height / 2]) {
    chamfer_cutter(bottom_height + 2, chamfer_size, CHAMFER_VERTICAL);
  }
  translate([outer_x, outer_y, bottom_height / 2]) {
    chamfer_cutter(bottom_height + 2, chamfer_size, CHAMFER_VERTICAL);
  }
}

// lip
translate([lip_offset_x, lip_offset_y, bottom_height]) {
  difference() {
    rounded_cube([lip_outer_x, lip_outer_y, lip_height], lip_fillet_radius);
    translate([lip_wall_thickness, lip_wall_thickness, -0.5]) {
      rounded_cube([interior_x, interior_y, lip_height + 2], lip_fillet_radius / 2);
    }
  }
  
  translate([detent_radius / 3, lip_outer_y / 3, lip_height / 2]) {
    sphere(r = detent_radius, $fn = facets);
  }
  translate([detent_radius / 3, 2 * lip_outer_y / 3, lip_height / 2]) {
    sphere(r = detent_radius, $fn = facets);
  }
  translate([lip_outer_x - detent_radius / 3, lip_outer_y / 3, lip_height / 2]) {
    sphere(r = detent_radius, $fn = facets);
  }
  translate([lip_outer_x - detent_radius / 3, 2 * lip_outer_y / 3, lip_height / 2]) {
    sphere(r = detent_radius, $fn = facets);
  }
}

// lid
translate([lid_x_position, lid_y_position, lid_z_position]) {
  rotate([lid_x_rotation, 0, 0]) {
    difference() {
      difference() {
        cube([outer_x, outer_y, lid_height]);
        translate([lid_wall_thickness, lid_wall_thickness, -0.1]) {
          rounded_cube([lid_interior_x, lid_interior_y, lid_interior_z + 0.1], lip_fillet_radius);
        }
        
        translate([lid_wall_thickness - detent_radius / 3, lid_interior_y / 3, lip_height / 2]) {
          sphere(r = detent_radius, $fn = facets);
        }
        translate([lid_wall_thickness - detent_radius / 3, 2 * lid_interior_y / 3, lip_height / 2]) {
          sphere(r = detent_radius, $fn = facets);
        }
        translate([outer_x - lid_wall_thickness + detent_radius / 3, lid_interior_y / 3, lip_height / 2]) {
          sphere(r = detent_radius, $fn = facets);
        }
        translate([outer_x - lid_wall_thickness + detent_radius / 3, 2 * lid_interior_y / 3, lip_height / 2]) {
          sphere(r = detent_radius, $fn = facets);
        }
      }

      translate([outer_x / 2, 0, lid_height]) {
        chamfer_cutter(outer_x + 2, chamfer_size, CHAMFER_TOP_HORIZONTAL_PARALLEL);
      }
      translate([outer_x / 2, outer_y, lid_height]) {
        chamfer_cutter(outer_x + 2, chamfer_size, CHAMFER_TOP_HORIZONTAL_PARALLEL);
      }
      translate([0, outer_y / 2, lid_height]) {
        chamfer_cutter(outer_y + 2, chamfer_size, CHAMFER_TOP_HORIZONTAL_PERPENDICULAR);
      }
      translate([outer_x, outer_y / 2, lid_height]) {
        chamfer_cutter(outer_y + 2, chamfer_size, CHAMFER_TOP_HORIZONTAL_PERPENDICULAR);
      }
      
      translate([0, 0, lid_height / 2]) {
        chamfer_cutter(lid_height + 2, chamfer_size, CHAMFER_VERTICAL);
      }
      translate([outer_x, 0, lid_height / 2]) {
        chamfer_cutter(lid_height + 2, chamfer_size, CHAMFER_VERTICAL);
      }
      translate([0, outer_y, lid_height / 2]) {
        chamfer_cutter(lid_height + 2, chamfer_size, CHAMFER_VERTICAL);
      }
      translate([outer_x, outer_y, lid_height / 2]) {
        chamfer_cutter(lid_height + 2, chamfer_size, CHAMFER_VERTICAL);
      }
    }
  }
}