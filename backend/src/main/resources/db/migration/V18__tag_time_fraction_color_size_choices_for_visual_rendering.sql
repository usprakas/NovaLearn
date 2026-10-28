-- Extends the SHAPE: visual-tag convention from V17 to four more content types, each handled by
-- the mobile client (core/widgets/choice_visual.dart):
--   CLOCK:<hour>:<minute>    -- a drawn analog clock face (the client formats its own label)
--   FRACTION:<numerator>:<denominator>:<Label> -- a divided circle with the numerator shaded
--   COLOR:<key>:<Label>      -- a filled color swatch
--   SIZE:<big|small>:<Label> -- a relative-size cue circle, for "which is bigger/longer" exercises
-- Coordinate-plane and "long hand points to N" clock visuals need no migration at all — the
-- client parses them straight out of the existing prompt text (e.g. "(3,5)", "points to the 3").

-- G2-TIME-01 (V10): telling time to the hour/half-hour
UPDATE exercise_choices SET choice_text = 'CLOCK:3:0' WHERE exercise_id = '21000000-0000-0000-0000-000000000013' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'CLOCK:12:0' WHERE exercise_id = '21000000-0000-0000-0000-000000000013' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'CLOCK:3:30' WHERE exercise_id = '21000000-0000-0000-0000-000000000013' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'CLOCK:7:30' WHERE exercise_id = '21000000-0000-0000-0000-000000000014' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'CLOCK:8:0' WHERE exercise_id = '21000000-0000-0000-0000-000000000014' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'CLOCK:6:30' WHERE exercise_id = '21000000-0000-0000-0000-000000000014' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'CLOCK:4:30' WHERE exercise_id = '21000000-0000-0000-0000-000000000015' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'CLOCK:5:0' WHERE exercise_id = '21000000-0000-0000-0000-000000000015' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'CLOCK:4:15' WHERE exercise_id = '21000000-0000-0000-0000-000000000015' AND choice_index = 2;

-- G3-FRAC-01 (V13): halves, thirds, fourths
UPDATE exercise_choices SET choice_text = 'FRACTION:1:2:1/2' WHERE exercise_id = '24000000-0000-0000-0000-000000000007' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:4:1/4' WHERE exercise_id = '24000000-0000-0000-0000-000000000007' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:3:1/3' WHERE exercise_id = '24000000-0000-0000-0000-000000000007' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'FRACTION:1:2:1/2' WHERE exercise_id = '24000000-0000-0000-0000-000000000008' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:3:1/3' WHERE exercise_id = '24000000-0000-0000-0000-000000000008' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:4:1/4' WHERE exercise_id = '24000000-0000-0000-0000-000000000008' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'FRACTION:1:2:A half' WHERE exercise_id = '24000000-0000-0000-0000-000000000009' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:3:A third' WHERE exercise_id = '24000000-0000-0000-0000-000000000009' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:4:A fourth' WHERE exercise_id = '24000000-0000-0000-0000-000000000009' AND choice_index = 2;

-- G4-FRACEQ-01 (V14): fraction equivalence
UPDATE exercise_choices SET choice_text = 'FRACTION:2:4:2/4' WHERE exercise_id = '25000000-0000-0000-0000-000000000007' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:3:1/3' WHERE exercise_id = '25000000-0000-0000-0000-000000000007' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:3:5:3/5' WHERE exercise_id = '25000000-0000-0000-0000-000000000007' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'FRACTION:3:4:3/4' WHERE exercise_id = '25000000-0000-0000-0000-000000000008' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:4:6:4/6' WHERE exercise_id = '25000000-0000-0000-0000-000000000008' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:2:1/2' WHERE exercise_id = '25000000-0000-0000-0000-000000000008' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'FRACTION:2:8:2/8' WHERE exercise_id = '25000000-0000-0000-0000-000000000009' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:2:5:2/5' WHERE exercise_id = '25000000-0000-0000-0000-000000000009' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:3:8:3/8' WHERE exercise_id = '25000000-0000-0000-0000-000000000009' AND choice_index = 2;

-- G4-FRACCOMP-01 (V14): comparing fractions (the "Equal" distractor choice is left untouched —
-- there's no single fraction value to diagram for it)
UPDATE exercise_choices SET choice_text = 'FRACTION:1:2:1/2' WHERE exercise_id = '25000000-0000-0000-0000-000000000010' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:4:1/4' WHERE exercise_id = '25000000-0000-0000-0000-000000000010' AND choice_index = 1;

UPDATE exercise_choices SET choice_text = 'FRACTION:2:3:2/3' WHERE exercise_id = '25000000-0000-0000-0000-000000000011' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:3:1/3' WHERE exercise_id = '25000000-0000-0000-0000-000000000011' AND choice_index = 1;

UPDATE exercise_choices SET choice_text = 'FRACTION:3:4:3/4' WHERE exercise_id = '25000000-0000-0000-0000-000000000012' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:2:1/2' WHERE exercise_id = '25000000-0000-0000-0000-000000000012' AND choice_index = 1;

-- G5-FRACADDSUB-01 (V15): adding/subtracting fractions
UPDATE exercise_choices SET choice_text = 'FRACTION:1:4:1/4' WHERE exercise_id = '26000000-0000-0000-0000-000000000001' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:3:4:3/4' WHERE exercise_id = '26000000-0000-0000-0000-000000000001' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:3:8:3/8' WHERE exercise_id = '26000000-0000-0000-0000-000000000001' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'FRACTION:2:5:2/5' WHERE exercise_id = '26000000-0000-0000-0000-000000000002' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:2:10:2/10' WHERE exercise_id = '26000000-0000-0000-0000-000000000002' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:4:5:4/5' WHERE exercise_id = '26000000-0000-0000-0000-000000000002' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'FRACTION:2:6:2/6' WHERE exercise_id = '26000000-0000-0000-0000-000000000003' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:3:4:3/4' WHERE exercise_id = '26000000-0000-0000-0000-000000000003' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:6:1/6' WHERE exercise_id = '26000000-0000-0000-0000-000000000003' AND choice_index = 2;

-- G5-FRACMULT-01 (V15): multiplying fractions
UPDATE exercise_choices SET choice_text = 'FRACTION:1:6:1/6' WHERE exercise_id = '26000000-0000-0000-0000-000000000004' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:1:5:1/5' WHERE exercise_id = '26000000-0000-0000-0000-000000000004' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:2:3:2/3' WHERE exercise_id = '26000000-0000-0000-0000-000000000004' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'FRACTION:1:3:1/3' WHERE exercise_id = '26000000-0000-0000-0000-000000000005' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:2:5:2/5' WHERE exercise_id = '26000000-0000-0000-0000-000000000005' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:3:6:3/6' WHERE exercise_id = '26000000-0000-0000-0000-000000000005' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'FRACTION:1:2:1/2' WHERE exercise_id = '26000000-0000-0000-0000-000000000006' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'FRACTION:5:7:5/7' WHERE exercise_id = '26000000-0000-0000-0000-000000000006' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'FRACTION:3:4:3/4' WHERE exercise_id = '26000000-0000-0000-0000-000000000006' AND choice_index = 2;

-- PK-COLOR-01 (V11): color recognition
UPDATE exercise_choices SET choice_text = 'COLOR:yellow:Yellow' WHERE exercise_id = '22000000-0000-0000-0000-000000000022' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'COLOR:purple:Purple' WHERE exercise_id = '22000000-0000-0000-0000-000000000022' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'COLOR:black:Black' WHERE exercise_id = '22000000-0000-0000-0000-000000000022' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'COLOR:green:Green' WHERE exercise_id = '22000000-0000-0000-0000-000000000023' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'COLOR:red:Red' WHERE exercise_id = '22000000-0000-0000-0000-000000000023' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'COLOR:pink:Pink' WHERE exercise_id = '22000000-0000-0000-0000-000000000023' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'COLOR:red:Red' WHERE exercise_id = '22000000-0000-0000-0000-000000000024' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'COLOR:blue:Blue' WHERE exercise_id = '22000000-0000-0000-0000-000000000024' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'COLOR:brown:Brown' WHERE exercise_id = '22000000-0000-0000-0000-000000000024' AND choice_index = 2;

-- PK-SIZE-01 (V11): size comparison (the "Same size" distractor is left untouched — there's
-- nothing relatively-bigger-or-smaller to show for it)
UPDATE exercise_choices SET choice_text = 'SIZE:big:Whale' WHERE exercise_id = '22000000-0000-0000-0000-000000000010' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SIZE:small:Fish' WHERE exercise_id = '22000000-0000-0000-0000-000000000010' AND choice_index = 1;

UPDATE exercise_choices SET choice_text = 'SIZE:big:Elephant' WHERE exercise_id = '22000000-0000-0000-0000-000000000011' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SIZE:small:Mouse' WHERE exercise_id = '22000000-0000-0000-0000-000000000011' AND choice_index = 1;

UPDATE exercise_choices SET choice_text = 'SIZE:small:Pencil' WHERE exercise_id = '22000000-0000-0000-0000-000000000012' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SIZE:big:Bus' WHERE exercise_id = '22000000-0000-0000-0000-000000000012' AND choice_index = 1;

-- K-MEASURE-01 (V12): length/height comparison
UPDATE exercise_choices SET choice_text = 'SIZE:big:Snake' WHERE exercise_id = '23000000-0000-0000-0000-000000000022' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SIZE:small:Worm' WHERE exercise_id = '23000000-0000-0000-0000-000000000022' AND choice_index = 1;

UPDATE exercise_choices SET choice_text = 'SIZE:big:Giraffe' WHERE exercise_id = '23000000-0000-0000-0000-000000000023' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SIZE:small:Dog' WHERE exercise_id = '23000000-0000-0000-0000-000000000023' AND choice_index = 1;
