-- Shape-recognition exercises (Pre-K, Kindergarten, Grade 2) asked a child to match a shape NAME
-- to a property ("which shape has 3 sides?") with no actual shape ever shown — defeating the
-- point of shape recognition, and reported directly by a user clicking through the app ("I can't
-- see the shapes"). Rather than adding an image/asset column to exercise_choices for what are
-- simple, precisely-describable geometric shapes (not photos), choice_text for shape-name answers
-- is tagged "SHAPE:<key>:<Label>" — the mobile client (core/widgets/shape_icon.dart) recognizes
-- this prefix and renders a real drawn vector shape next to the label instead of plain text.
-- Numeric-answer shape exercises (side/corner counts) are untouched; there's no shape name to tag.

-- PK-SHAPE-01
UPDATE exercise_choices SET choice_text = 'SHAPE:circle:Circle' WHERE exercise_id = '22000000-0000-0000-0000-000000000007' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SHAPE:square:Square' WHERE exercise_id = '22000000-0000-0000-0000-000000000007' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'SHAPE:triangle:Triangle' WHERE exercise_id = '22000000-0000-0000-0000-000000000007' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'SHAPE:square:Square' WHERE exercise_id = '22000000-0000-0000-0000-000000000008' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SHAPE:triangle:Triangle' WHERE exercise_id = '22000000-0000-0000-0000-000000000008' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'SHAPE:circle:Circle' WHERE exercise_id = '22000000-0000-0000-0000-000000000008' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'SHAPE:triangle:Triangle' WHERE exercise_id = '22000000-0000-0000-0000-000000000009' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SHAPE:circle:Circle' WHERE exercise_id = '22000000-0000-0000-0000-000000000009' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'SHAPE:square:Square' WHERE exercise_id = '22000000-0000-0000-0000-000000000009' AND choice_index = 2;

-- K-SHAPE-01
UPDATE exercise_choices SET choice_text = 'SHAPE:pentagon:Pentagon' WHERE exercise_id = '23000000-0000-0000-0000-000000000019' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SHAPE:square:Square' WHERE exercise_id = '23000000-0000-0000-0000-000000000019' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'SHAPE:circle:Circle' WHERE exercise_id = '23000000-0000-0000-0000-000000000019' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'SHAPE:triangle:Triangle' WHERE exercise_id = '23000000-0000-0000-0000-000000000020' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SHAPE:circle:Circle' WHERE exercise_id = '23000000-0000-0000-0000-000000000020' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'SHAPE:rectangle:Rectangle' WHERE exercise_id = '23000000-0000-0000-0000-000000000020' AND choice_index = 2;

UPDATE exercise_choices SET choice_text = 'SHAPE:rectangle:Rectangle' WHERE exercise_id = '23000000-0000-0000-0000-000000000021' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SHAPE:circle:Circle' WHERE exercise_id = '23000000-0000-0000-0000-000000000021' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'SHAPE:triangle:Triangle' WHERE exercise_id = '23000000-0000-0000-0000-000000000021' AND choice_index = 2;

-- G2-SHAPE-01 (2D vs. 3D comparison)
UPDATE exercise_choices SET choice_text = 'SHAPE:circle:Circle' WHERE exercise_id = '21000000-0000-0000-0000-000000000023' AND choice_index = 0;
UPDATE exercise_choices SET choice_text = 'SHAPE:sphere:Sphere' WHERE exercise_id = '21000000-0000-0000-0000-000000000023' AND choice_index = 1;
UPDATE exercise_choices SET choice_text = 'SHAPE:square:Square' WHERE exercise_id = '21000000-0000-0000-0000-000000000023' AND choice_index = 2;
