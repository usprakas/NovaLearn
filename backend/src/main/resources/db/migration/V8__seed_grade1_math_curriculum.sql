-- Grade 1 Math only, matching the master spec's MVP scope exactly: "Counting and number
-- recognition, Addition, Subtraction, Number comparison, Simple word problems." English content
-- added in an earlier pre-spec session is intentionally not carried into the DB-backed catalog —
-- see docs/DATABASE_DESIGN.md.

INSERT INTO subjects (code, name) VALUES ('MATH', 'Mathematics');

INSERT INTO skills (code, subject_code, name) VALUES
    ('COUNTING', 'MATH', 'Counting and Number Recognition'),
    ('ADDITION', 'MATH', 'Addition'),
    ('SUBTRACTION', 'MATH', 'Subtraction'),
    ('COMPARISON', 'MATH', 'Number Comparison'),
    ('WORD_PROBLEMS', 'MATH', 'Simple Word Problems');

INSERT INTO lessons (id, code, subject_code, display_order, title, description) VALUES
    ('10000000-0000-0000-0000-000000000001', 'G1-COUNT-01', 'MATH', 1, 'Counting and Number Recognition', 'Count objects and recognize numbers up to 20.'),
    ('10000000-0000-0000-0000-000000000002', 'G1-ADD-01', 'MATH', 2, 'Adding within 10', 'Use pictures and counting to add two small numbers.'),
    ('10000000-0000-0000-0000-000000000003', 'G1-SUB-01', 'MATH', 3, 'Subtracting within 10', 'Take away objects and count what is left.'),
    ('10000000-0000-0000-0000-000000000004', 'G1-CMP-01', 'MATH', 4, 'Comparing Numbers', 'Compare two numbers to see which is greater, less, or equal.'),
    ('10000000-0000-0000-0000-000000000005', 'G1-WORD-01', 'MATH', 5, 'Simple Word Problems', 'Solve short real-world problems using addition and subtraction.');

INSERT INTO exercises (id, lesson_code, skill_code, display_order, prompt, answer_index, explanation, hint) VALUES
    ('20000000-0000-0000-0000-000000000001', 'G1-COUNT-01', 'COUNTING', 1, 'How many apples are in the picture: apple apple apple apple?', 1, 'There are 4 apples -- count each one: 1, 2, 3, 4.', 'Try pointing to each apple and counting out loud.'),
    ('20000000-0000-0000-0000-000000000002', 'G1-COUNT-01', 'COUNTING', 2, 'What number comes right after 7?', 1, 'After 7 comes 8 -- just add one more!', 'Count up from 7: 7, then...?'),
    ('20000000-0000-0000-0000-000000000003', 'G1-COUNT-01', 'COUNTING', 3, 'Which number is this: 12?', 0, '12 is read as "twelve".', 'The first digit is 1 (ten) and the second is 2.'),

    ('20000000-0000-0000-0000-000000000004', 'G1-ADD-01', 'ADDITION', 1, 'Maya has 2 apples. Her friend gives her 3 more. How many apples does Maya have?', 1, '2 apples plus 3 more apples makes 5 apples in total.', 'Try counting up from 2: 3, 4, 5.'),
    ('20000000-0000-0000-0000-000000000005', 'G1-ADD-01', 'ADDITION', 2, 'What is 4 + 1?', 2, '4 + 1 = 5.', 'Count one more after 4.'),
    ('20000000-0000-0000-0000-000000000006', 'G1-ADD-01', 'ADDITION', 3, 'What is 3 + 3?', 1, '3 + 3 = 6.', 'Try using your fingers: 3 on one hand, 3 on the other.'),

    ('20000000-0000-0000-0000-000000000007', 'G1-SUB-01', 'SUBTRACTION', 1, 'Leo has 5 stickers and gives away 2. How many does he have left?', 1, '5 stickers minus 2 given away leaves 3 stickers.', 'Start at 5 and count back 2.'),
    ('20000000-0000-0000-0000-000000000008', 'G1-SUB-01', 'SUBTRACTION', 2, 'What is 6 - 4?', 1, '6 - 4 = 2.', 'Count back from 6: 5, 4... that is 2 steps.'),
    ('20000000-0000-0000-0000-000000000009', 'G1-SUB-01', 'SUBTRACTION', 3, 'What is 9 - 3?', 1, '9 - 3 = 6.', 'Try counting backward from 9 three times.'),

    ('20000000-0000-0000-0000-000000000010', 'G1-CMP-01', 'COMPARISON', 1, 'Which number is greater: 8 or 5?', 1, '8 is greater than 5 because it comes later when counting.', 'Count up: which number do you reach first?'),
    ('20000000-0000-0000-0000-000000000011', 'G1-CMP-01', 'COMPARISON', 2, 'Which sign makes this true: 6 ? 6', 2, '6 and 6 are the same number, so they are equal.', 'Are the two numbers the same?'),
    ('20000000-0000-0000-0000-000000000012', 'G1-CMP-01', 'COMPARISON', 3, 'Which number is smaller: 10 or 3?', 1, '3 is smaller than 10.', 'Think about which number you would say first when counting up.'),

    ('20000000-0000-0000-0000-000000000013', 'G1-WORD-01', 'WORD_PROBLEMS', 1, 'There are 3 birds on a branch. 2 more birds land on it. How many birds are on the branch now?', 1, '3 birds plus 2 more birds makes 5 birds.', 'This is an adding problem -- try counting up from 3.'),
    ('20000000-0000-0000-0000-000000000014', 'G1-WORD-01', 'WORD_PROBLEMS', 2, 'Sam had 7 crayons. He lost 2 of them. How many crayons does Sam have now?', 1, '7 crayons minus the 2 lost leaves 5 crayons.', 'This is a taking-away problem -- count back from 7.'),
    ('20000000-0000-0000-0000-000000000015', 'G1-WORD-01', 'WORD_PROBLEMS', 3, 'There are 4 ducks swimming. 4 more ducks join them. How many ducks are there in total?', 1, '4 ducks plus 4 more ducks makes 8 ducks.', 'Try doubling 4.');

INSERT INTO exercise_choices (exercise_id, choice_index, choice_text) VALUES
    ('20000000-0000-0000-0000-000000000001', 0, '3'), ('20000000-0000-0000-0000-000000000001', 1, '4'), ('20000000-0000-0000-0000-000000000001', 2, '5'),
    ('20000000-0000-0000-0000-000000000002', 0, '6'), ('20000000-0000-0000-0000-000000000002', 1, '8'), ('20000000-0000-0000-0000-000000000002', 2, '9'),
    ('20000000-0000-0000-0000-000000000003', 0, 'Twelve'), ('20000000-0000-0000-0000-000000000003', 1, 'Twenty-one'), ('20000000-0000-0000-0000-000000000003', 2, 'Two'),

    ('20000000-0000-0000-0000-000000000004', 0, '4'), ('20000000-0000-0000-0000-000000000004', 1, '5'), ('20000000-0000-0000-0000-000000000004', 2, '6'),
    ('20000000-0000-0000-0000-000000000005', 0, '3'), ('20000000-0000-0000-0000-000000000005', 1, '4'), ('20000000-0000-0000-0000-000000000005', 2, '5'),
    ('20000000-0000-0000-0000-000000000006', 0, '5'), ('20000000-0000-0000-0000-000000000006', 1, '6'), ('20000000-0000-0000-0000-000000000006', 2, '7'),

    ('20000000-0000-0000-0000-000000000007', 0, '2'), ('20000000-0000-0000-0000-000000000007', 1, '3'), ('20000000-0000-0000-0000-000000000007', 2, '4'),
    ('20000000-0000-0000-0000-000000000008', 0, '1'), ('20000000-0000-0000-0000-000000000008', 1, '2'), ('20000000-0000-0000-0000-000000000008', 2, '3'),
    ('20000000-0000-0000-0000-000000000009', 0, '5'), ('20000000-0000-0000-0000-000000000009', 1, '6'), ('20000000-0000-0000-0000-000000000009', 2, '7'),

    ('20000000-0000-0000-0000-000000000010', 0, '5'), ('20000000-0000-0000-0000-000000000010', 1, '8'), ('20000000-0000-0000-0000-000000000010', 2, 'They are equal'),
    ('20000000-0000-0000-0000-000000000011', 0, 'Greater than (>)'), ('20000000-0000-0000-0000-000000000011', 1, 'Less than (<)'), ('20000000-0000-0000-0000-000000000011', 2, 'Equal to (=)'),
    ('20000000-0000-0000-0000-000000000012', 0, '10'), ('20000000-0000-0000-0000-000000000012', 1, '3'), ('20000000-0000-0000-0000-000000000012', 2, 'They are equal'),

    ('20000000-0000-0000-0000-000000000013', 0, '4'), ('20000000-0000-0000-0000-000000000013', 1, '5'), ('20000000-0000-0000-0000-000000000013', 2, '6'),
    ('20000000-0000-0000-0000-000000000014', 0, '4'), ('20000000-0000-0000-0000-000000000014', 1, '5'), ('20000000-0000-0000-0000-000000000014', 2, '6'),
    ('20000000-0000-0000-0000-000000000015', 0, '7'), ('20000000-0000-0000-0000-000000000015', 1, '8'), ('20000000-0000-0000-0000-000000000015', 2, '9');
