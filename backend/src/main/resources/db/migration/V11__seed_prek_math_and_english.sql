-- Pre-K curriculum: 9 Math lessons + 8 English lessons. Exercises lean on repeated emoji for
-- quantities/visuals (the same trick already used in V8's Grade 1 counting lesson) since Pre-K
-- content is fundamentally concrete/visual, and choices are kept to single words or short
-- phrases since this age group is pre-literacy — a parent or the app's text-to-speech reads the
-- prompt aloud (see the mobile tutor/homework voice feature) rather than the child reading it.

INSERT INTO skills (code, subject_code, name) VALUES
    ('COUNT_1_5', 'MATH', 'Counting 1 to 5'),
    ('COUNT_6_10', 'MATH', 'Counting 6 to 10'),
    ('SHAPES_PK', 'MATH', 'Shape Recognition'),
    ('SIZE_COMPARE', 'MATH', 'Big and Small'),
    ('SAME_DIFF', 'MATH', 'Same and Different'),
    ('PATTERNS_PK', 'MATH', 'Simple Patterns'),
    ('POSITION_WORDS', 'MATH', 'Position Words'),
    ('COLORS_PK', 'MATH', 'Color Recognition'),
    ('SORTING_PK', 'MATH', 'Sorting and Classifying'),
    ('LETTERS_A_M', 'ENGLISH', 'Letters A to M'),
    ('LETTERS_N_Z', 'ENGLISH', 'Letters N to Z'),
    ('LETTER_SOUNDS_PK', 'ENGLISH', 'Beginning Letter Sounds'),
    ('RHYMING_PK', 'ENGLISH', 'Rhyming Words'),
    ('LISTENING_PK', 'ENGLISH', 'Listening and Understanding'),
    ('VOCAB_PK', 'ENGLISH', 'Everyday Words'),
    ('SOUND_DISCRIM', 'ENGLISH', 'Same or Different Sounds'),
    ('DIRECTIONS_PK', 'ENGLISH', 'Following Simple Directions');

INSERT INTO lessons (id, code, subject_code, grade_level, display_order, title, description) VALUES
    ('12000000-0000-0000-0000-000000000001', 'PK-COUNT1-01', 'MATH', 'PRE_K', 1, 'Counting 1 to 5', 'Count small groups of objects up to 5.'),
    ('12000000-0000-0000-0000-000000000002', 'PK-COUNT2-01', 'MATH', 'PRE_K', 2, 'Counting 6 to 10', 'Count groups of objects up to 10.'),
    ('12000000-0000-0000-0000-000000000003', 'PK-SHAPE-01', 'MATH', 'PRE_K', 3, 'Shape Recognition', 'Name circles, triangles, and squares.'),
    ('12000000-0000-0000-0000-000000000004', 'PK-SIZE-01', 'MATH', 'PRE_K', 4, 'Big and Small', 'Compare the size of two things.'),
    ('12000000-0000-0000-0000-000000000005', 'PK-SAME-01', 'MATH', 'PRE_K', 5, 'Same and Different', 'Decide whether two things match.'),
    ('12000000-0000-0000-0000-000000000006', 'PK-PATTERN-01', 'MATH', 'PRE_K', 6, 'Simple Patterns', 'Figure out what comes next in a repeating pattern.'),
    ('12000000-0000-0000-0000-000000000007', 'PK-POSITION-01', 'MATH', 'PRE_K', 7, 'Position Words', 'Understand on, under, and inside.'),
    ('12000000-0000-0000-0000-000000000008', 'PK-COLOR-01', 'MATH', 'PRE_K', 8, 'Color Recognition', 'Name common colors.'),
    ('12000000-0000-0000-0000-000000000009', 'PK-SORT-01', 'MATH', 'PRE_K', 9, 'Sorting and Classifying', 'Find the thing that does not belong in a group.'),
    ('12000000-0000-0000-0000-000000000010', 'PK-ENG-LETTERS1-01', 'ENGLISH', 'PRE_K', 1, 'Letters A to M', 'Recognize the first half of the alphabet.'),
    ('12000000-0000-0000-0000-000000000011', 'PK-ENG-LETTERS2-01', 'ENGLISH', 'PRE_K', 2, 'Letters N to Z', 'Recognize the second half of the alphabet.'),
    ('12000000-0000-0000-0000-000000000012', 'PK-ENG-SOUNDS-01', 'ENGLISH', 'PRE_K', 3, 'Beginning Letter Sounds', 'Hear the first sound in a word.'),
    ('12000000-0000-0000-0000-000000000013', 'PK-ENG-RHYME-01', 'ENGLISH', 'PRE_K', 4, 'Rhyming Words', 'Find words that sound alike at the end.'),
    ('12000000-0000-0000-0000-000000000014', 'PK-ENG-LISTEN-01', 'ENGLISH', 'PRE_K', 5, 'Listening and Understanding', 'Answer a question about a short story.'),
    ('12000000-0000-0000-0000-000000000015', 'PK-ENG-VOCAB-01', 'ENGLISH', 'PRE_K', 6, 'Everyday Words', 'Name things we use every day.'),
    ('12000000-0000-0000-0000-000000000016', 'PK-ENG-SOUNDDISC-01', 'ENGLISH', 'PRE_K', 7, 'Same or Different Sounds', 'Compare the sounds in two words.'),
    ('12000000-0000-0000-0000-000000000017', 'PK-ENG-DIRECTIONS-01', 'ENGLISH', 'PRE_K', 8, 'Following Simple Directions', 'Understand a one-step instruction.');

INSERT INTO exercises (id, lesson_code, skill_code, display_order, prompt, answer_index, explanation, hint) VALUES
    ('22000000-0000-0000-0000-000000000001', 'PK-COUNT1-01', 'COUNT_1_5', 1, 'Count the stars: star star star. How many stars?', 1, 'There are 3 stars.', 'Point to each one and count out loud.'),
    ('22000000-0000-0000-0000-000000000002', 'PK-COUNT1-01', 'COUNT_1_5', 2, 'Count the apples: apple apple. How many apples?', 1, 'There are 2 apples.', 'Point to each one and count out loud.'),
    ('22000000-0000-0000-0000-000000000003', 'PK-COUNT1-01', 'COUNT_1_5', 3, 'Count the cats: cat cat cat cat cat. How many cats?', 1, 'There are 5 cats.', 'Point to each one and count out loud.'),

    ('22000000-0000-0000-0000-000000000004', 'PK-COUNT2-01', 'COUNT_6_10', 1, 'Count the balloons: balloon balloon balloon balloon balloon balloon balloon. How many balloons?', 1, 'There are 7 balloons.', 'Keep counting past 5: 6, 7.'),
    ('22000000-0000-0000-0000-000000000005', 'PK-COUNT2-01', 'COUNT_6_10', 2, 'Count the dots: dot dot dot dot dot dot dot dot. How many dots?', 1, 'There are 8 dots.', 'Keep counting past 5: 6, 7, 8.'),
    ('22000000-0000-0000-0000-000000000006', 'PK-COUNT2-01', 'COUNT_6_10', 3, 'Count the stars: star star star star star star star star star star. How many stars?', 1, 'There are 10 stars.', 'Keep counting all the way to 10.'),

    ('22000000-0000-0000-0000-000000000007', 'PK-SHAPE-01', 'SHAPES_PK', 1, 'Which shape is round like a ball?', 0, 'A circle is round like a ball.', 'Think of a wheel or the sun.'),
    ('22000000-0000-0000-0000-000000000008', 'PK-SHAPE-01', 'SHAPES_PK', 2, 'Which shape has 3 sides?', 1, 'A triangle has 3 sides.', 'Think of a slice of pizza.'),
    ('22000000-0000-0000-0000-000000000009', 'PK-SHAPE-01', 'SHAPES_PK', 3, 'Which shape has 4 equal sides?', 2, 'A square has 4 equal sides.', 'Think of a window pane.'),

    ('22000000-0000-0000-0000-000000000010', 'PK-SIZE-01', 'SIZE_COMPARE', 1, 'A whale and a fish. Which one is bigger?', 0, 'A whale is much bigger than a fish.', 'Picture the two animals next to each other.'),
    ('22000000-0000-0000-0000-000000000011', 'PK-SIZE-01', 'SIZE_COMPARE', 2, 'An elephant and a mouse. Which one is smaller?', 1, 'A mouse is much smaller than an elephant.', 'Picture the two animals next to each other.'),
    ('22000000-0000-0000-0000-000000000012', 'PK-SIZE-01', 'SIZE_COMPARE', 3, 'A pencil and a bus. Which one is longer?', 1, 'A bus is much longer than a pencil.', 'Picture the two things next to each other.'),

    ('22000000-0000-0000-0000-000000000013', 'PK-SAME-01', 'SAME_DIFF', 1, 'A red circle and a red circle. Are they the same color?', 0, 'Both circles are red, so they are the same color.', 'Look closely at each color.'),
    ('22000000-0000-0000-0000-000000000014', 'PK-SAME-01', 'SAME_DIFF', 2, 'A red circle and a blue circle. Are they the same color?', 1, 'One is red and one is blue, so they are different colors.', 'Look closely at each color.'),
    ('22000000-0000-0000-0000-000000000015', 'PK-SAME-01', 'SAME_DIFF', 3, 'Is a dog the same kind of animal as a cat?', 1, 'A dog and a cat are different kinds of animals.', 'Think about what makes each animal special.'),

    ('22000000-0000-0000-0000-000000000016', 'PK-PATTERN-01', 'PATTERNS_PK', 1, 'What comes next: red, blue, red, blue, __?', 0, 'The pattern alternates red and blue, so red comes next.', 'The pattern repeats every two.'),
    ('22000000-0000-0000-0000-000000000017', 'PK-PATTERN-01', 'PATTERNS_PK', 2, 'What comes next: star, moon, star, moon, __?', 0, 'The pattern alternates star and moon, so star comes next.', 'The pattern repeats every two.'),
    ('22000000-0000-0000-0000-000000000018', 'PK-PATTERN-01', 'PATTERNS_PK', 3, 'What comes next: green, green, yellow, green, green, __?', 1, 'The pattern is two greens then one yellow, so yellow comes next.', 'Count how many of one color come before the pattern changes.'),

    ('22000000-0000-0000-0000-000000000019', 'PK-POSITION-01', 'POSITION_WORDS', 1, 'If a bird is sitting on the branch, where is the bird?', 1, '"On" means the bird is resting on top of the branch.', 'Think about what "on" means.'),
    ('22000000-0000-0000-0000-000000000020', 'PK-POSITION-01', 'POSITION_WORDS', 2, 'If a ball rolled under the table, where is the ball?', 1, '"Under" means the ball is beneath the table.', 'Think about what "under" means.'),
    ('22000000-0000-0000-0000-000000000021', 'PK-POSITION-01', 'POSITION_WORDS', 3, 'If a toy is inside the box, where is the toy?', 1, '"Inside" means the toy is within the box.', 'Think about what "inside" means.'),

    ('22000000-0000-0000-0000-000000000022', 'PK-COLOR-01', 'COLORS_PK', 1, 'What color is the sun usually drawn as?', 0, 'The sun is usually drawn yellow.', 'Think about pictures of the sun you have seen.'),
    ('22000000-0000-0000-0000-000000000023', 'PK-COLOR-01', 'COLORS_PK', 2, 'What color do you get when you mix blue and yellow?', 0, 'Blue and yellow mix to make green.', 'Think about mixing paint colors.'),
    ('22000000-0000-0000-0000-000000000024', 'PK-COLOR-01', 'COLORS_PK', 3, 'What color is a ripe strawberry?', 0, 'A ripe strawberry is red.', 'Think about the fruit''s color when it is ready to eat.'),

    ('22000000-0000-0000-0000-000000000025', 'PK-SORT-01', 'SORTING_PK', 1, 'Which one does not belong: apple, banana, car, orange?', 2, 'A car is not a fruit, so it does not belong with the others.', 'Three of these are fruits.'),
    ('22000000-0000-0000-0000-000000000026', 'PK-SORT-01', 'SORTING_PK', 2, 'Which group is all animals: dog, cat, bird OR car, bus, bike?', 0, 'Dog, cat, and bird are all animals.', 'Think about which group is made of living things.'),
    ('22000000-0000-0000-0000-000000000027', 'PK-SORT-01', 'SORTING_PK', 3, 'Which one is not a fruit: strawberry, grape, chair?', 2, 'A chair is furniture, not a fruit.', 'Two of these grow on plants and can be eaten.'),

    ('22000000-0000-0000-0000-000000000028', 'PK-ENG-LETTERS1-01', 'LETTERS_A_M', 1, 'Which letter comes first in the alphabet?', 0, 'A is the first letter of the alphabet.', 'Think about how the alphabet song starts.'),
    ('22000000-0000-0000-0000-000000000029', 'PK-ENG-LETTERS1-01', 'LETTERS_A_M', 2, 'Which of these is the letter B?', 1, 'The second choice shows the letter B.', 'B comes right after A.'),
    ('22000000-0000-0000-0000-000000000030', 'PK-ENG-LETTERS1-01', 'LETTERS_A_M', 3, 'What letter does "Apple" start with?', 0, '"Apple" starts with the letter A.', 'Say the word slowly and listen to the first sound.'),

    ('22000000-0000-0000-0000-000000000031', 'PK-ENG-LETTERS2-01', 'LETTERS_N_Z', 1, 'Which letter is the very last one in the alphabet?', 2, 'Z is the last letter of the alphabet.', 'Think about how the alphabet song ends.'),
    ('22000000-0000-0000-0000-000000000032', 'PK-ENG-LETTERS2-01', 'LETTERS_N_Z', 2, 'What letter does "Zebra" start with?', 0, '"Zebra" starts with the letter Z.', 'Say the word slowly and listen to the first sound.'),
    ('22000000-0000-0000-0000-000000000033', 'PK-ENG-LETTERS2-01', 'LETTERS_N_Z', 3, 'Which letter comes right after N?', 1, 'O comes right after N in the alphabet.', 'Think about the order of the alphabet.'),

    ('22000000-0000-0000-0000-000000000034', 'PK-ENG-SOUNDS-01', 'LETTER_SOUNDS_PK', 1, 'What sound does "Ball" start with?', 0, '"Ball" starts with the B sound.', 'Say the word slowly and listen to the first sound.'),
    ('22000000-0000-0000-0000-000000000035', 'PK-ENG-SOUNDS-01', 'LETTER_SOUNDS_PK', 2, 'What sound does "Cat" start with?', 0, '"Cat" starts with the K sound, spelled with C.', 'Say the word slowly and listen to the first sound.'),
    ('22000000-0000-0000-0000-000000000036', 'PK-ENG-SOUNDS-01', 'LETTER_SOUNDS_PK', 3, 'What sound does "Dog" start with?', 0, '"Dog" starts with the D sound.', 'Say the word slowly and listen to the first sound.'),

    ('22000000-0000-0000-0000-000000000037', 'PK-ENG-RHYME-01', 'RHYMING_PK', 1, 'Which word rhymes with "cat"?', 0, '"Hat" rhymes with "cat" — they both end in "at".', 'Rhyming words end with the same sound.'),
    ('22000000-0000-0000-0000-000000000038', 'PK-ENG-RHYME-01', 'RHYMING_PK', 2, 'Which word rhymes with "ball"?', 1, '"Tall" rhymes with "ball" — they both end in "all".', 'Rhyming words end with the same sound.'),
    ('22000000-0000-0000-0000-000000000039', 'PK-ENG-RHYME-01', 'RHYMING_PK', 3, 'Which word rhymes with "sun"?', 0, '"Fun" rhymes with "sun" — they both end in "un".', 'Rhyming words end with the same sound.'),

    ('22000000-0000-0000-0000-000000000040', 'PK-ENG-LISTEN-01', 'LISTENING_PK', 1, 'A little duck lost its way home. Who is the story about?', 0, 'The story is about a duck.', 'Listen for the name of the character.'),
    ('22000000-0000-0000-0000-000000000041', 'PK-ENG-LISTEN-01', 'LISTENING_PK', 2, 'A bear found honey in a tree. What did the bear find?', 0, 'The bear found honey.', 'Listen for what the bear discovered.'),
    ('22000000-0000-0000-0000-000000000042', 'PK-ENG-LISTEN-01', 'LISTENING_PK', 3, 'A girl planted a seed and it grew into a flower. What grew?', 1, 'The seed grew into a flower.', 'Listen for what the seed became.'),

    ('22000000-0000-0000-0000-000000000043', 'PK-ENG-VOCAB-01', 'VOCAB_PK', 1, 'What do you use to brush your teeth?', 0, 'We use a toothbrush to brush our teeth.', 'Think about your morning routine.'),
    ('22000000-0000-0000-0000-000000000044', 'PK-ENG-VOCAB-01', 'VOCAB_PK', 2, 'What do you wear on your feet?', 1, 'We wear shoes on our feet.', 'Think about getting ready to go outside.'),
    ('22000000-0000-0000-0000-000000000045', 'PK-ENG-VOCAB-01', 'VOCAB_PK', 3, 'What do you drink when you are thirsty?', 0, 'We drink water when we are thirsty.', 'Think about what helps when your mouth feels dry.'),

    ('22000000-0000-0000-0000-000000000046', 'PK-ENG-SOUNDDISC-01', 'SOUND_DISCRIM', 1, 'Which word ends with the same sound as "cat"?', 0, '"Bat" ends with the same "at" sound as "cat".', 'Listen to the very end of each word.'),
    ('22000000-0000-0000-0000-000000000047', 'PK-ENG-SOUNDDISC-01', 'SOUND_DISCRIM', 2, 'Which word starts with the same sound as "dog"?', 1, '"Duck" starts with the same D sound as "dog".', 'Listen to the very beginning of each word.'),
    ('22000000-0000-0000-0000-000000000048', 'PK-ENG-SOUNDDISC-01', 'SOUND_DISCRIM', 3, 'Which two words rhyme?', 0, '"Sun" and "Fun" rhyme because they end with the same sound.', 'Rhyming words share an ending sound.'),

    ('22000000-0000-0000-0000-000000000049', 'PK-ENG-DIRECTIONS-01', 'DIRECTIONS_PK', 1, 'If your teacher says "stand up," what should you do?', 1, '"Stand up" means to get up on your feet.', 'Listen for the action word.'),
    ('22000000-0000-0000-0000-000000000050', 'PK-ENG-DIRECTIONS-01', 'DIRECTIONS_PK', 2, 'If your teacher says "touch your nose," what should you touch?', 0, '"Touch your nose" means to put your finger on your nose.', 'Listen for which body part is named.'),
    ('22000000-0000-0000-0000-000000000051', 'PK-ENG-DIRECTIONS-01', 'DIRECTIONS_PK', 3, 'If your teacher says "raise your hand," what should you raise?', 0, '"Raise your hand" means to lift your hand up in the air.', 'Listen for which body part is named.');

INSERT INTO exercise_choices (exercise_id, choice_index, choice_text) VALUES
    ('22000000-0000-0000-0000-000000000001', 0, '2'), ('22000000-0000-0000-0000-000000000001', 1, '3'), ('22000000-0000-0000-0000-000000000001', 2, '4'),
    ('22000000-0000-0000-0000-000000000002', 0, '1'), ('22000000-0000-0000-0000-000000000002', 1, '2'), ('22000000-0000-0000-0000-000000000002', 2, '3'),
    ('22000000-0000-0000-0000-000000000003', 0, '4'), ('22000000-0000-0000-0000-000000000003', 1, '5'), ('22000000-0000-0000-0000-000000000003', 2, '6'),

    ('22000000-0000-0000-0000-000000000004', 0, '6'), ('22000000-0000-0000-0000-000000000004', 1, '7'), ('22000000-0000-0000-0000-000000000004', 2, '8'),
    ('22000000-0000-0000-0000-000000000005', 0, '7'), ('22000000-0000-0000-0000-000000000005', 1, '8'), ('22000000-0000-0000-0000-000000000005', 2, '9'),
    ('22000000-0000-0000-0000-000000000006', 0, '9'), ('22000000-0000-0000-0000-000000000006', 1, '10'), ('22000000-0000-0000-0000-000000000006', 2, '11'),

    ('22000000-0000-0000-0000-000000000007', 0, 'Circle'), ('22000000-0000-0000-0000-000000000007', 1, 'Square'), ('22000000-0000-0000-0000-000000000007', 2, 'Triangle'),
    ('22000000-0000-0000-0000-000000000008', 0, 'Square'), ('22000000-0000-0000-0000-000000000008', 1, 'Triangle'), ('22000000-0000-0000-0000-000000000008', 2, 'Circle'),
    ('22000000-0000-0000-0000-000000000009', 0, 'Triangle'), ('22000000-0000-0000-0000-000000000009', 1, 'Circle'), ('22000000-0000-0000-0000-000000000009', 2, 'Square'),

    ('22000000-0000-0000-0000-000000000010', 0, 'Whale'), ('22000000-0000-0000-0000-000000000010', 1, 'Fish'), ('22000000-0000-0000-0000-000000000010', 2, 'Same size'),
    ('22000000-0000-0000-0000-000000000011', 0, 'Elephant'), ('22000000-0000-0000-0000-000000000011', 1, 'Mouse'), ('22000000-0000-0000-0000-000000000011', 2, 'Same size'),
    ('22000000-0000-0000-0000-000000000012', 0, 'Pencil'), ('22000000-0000-0000-0000-000000000012', 1, 'Bus'), ('22000000-0000-0000-0000-000000000012', 2, 'Same size'),

    ('22000000-0000-0000-0000-000000000013', 0, 'Yes'), ('22000000-0000-0000-0000-000000000013', 1, 'No'), ('22000000-0000-0000-0000-000000000013', 2, 'Can''t tell'),
    ('22000000-0000-0000-0000-000000000014', 0, 'Yes'), ('22000000-0000-0000-0000-000000000014', 1, 'No'), ('22000000-0000-0000-0000-000000000014', 2, 'Can''t tell'),
    ('22000000-0000-0000-0000-000000000015', 0, 'Yes'), ('22000000-0000-0000-0000-000000000015', 1, 'No'), ('22000000-0000-0000-0000-000000000015', 2, 'Can''t tell'),

    ('22000000-0000-0000-0000-000000000016', 0, 'Red'), ('22000000-0000-0000-0000-000000000016', 1, 'Blue'), ('22000000-0000-0000-0000-000000000016', 2, 'Green'),
    ('22000000-0000-0000-0000-000000000017', 0, 'Star'), ('22000000-0000-0000-0000-000000000017', 1, 'Moon'), ('22000000-0000-0000-0000-000000000017', 2, 'Sun'),
    ('22000000-0000-0000-0000-000000000018', 0, 'Green'), ('22000000-0000-0000-0000-000000000018', 1, 'Yellow'), ('22000000-0000-0000-0000-000000000018', 2, 'Blue'),

    ('22000000-0000-0000-0000-000000000019', 0, 'Under the branch'), ('22000000-0000-0000-0000-000000000019', 1, 'On the branch'), ('22000000-0000-0000-0000-000000000019', 2, 'Inside the branch'),
    ('22000000-0000-0000-0000-000000000020', 0, 'On the table'), ('22000000-0000-0000-0000-000000000020', 1, 'Under the table'), ('22000000-0000-0000-0000-000000000020', 2, 'Above the table'),
    ('22000000-0000-0000-0000-000000000021', 0, 'Outside the box'), ('22000000-0000-0000-0000-000000000021', 1, 'Inside the box'), ('22000000-0000-0000-0000-000000000021', 2, 'Next to the box'),

    ('22000000-0000-0000-0000-000000000022', 0, 'Yellow'), ('22000000-0000-0000-0000-000000000022', 1, 'Purple'), ('22000000-0000-0000-0000-000000000022', 2, 'Black'),
    ('22000000-0000-0000-0000-000000000023', 0, 'Green'), ('22000000-0000-0000-0000-000000000023', 1, 'Red'), ('22000000-0000-0000-0000-000000000023', 2, 'Pink'),
    ('22000000-0000-0000-0000-000000000024', 0, 'Red'), ('22000000-0000-0000-0000-000000000024', 1, 'Blue'), ('22000000-0000-0000-0000-000000000024', 2, 'Brown'),

    ('22000000-0000-0000-0000-000000000025', 0, 'Apple'), ('22000000-0000-0000-0000-000000000025', 1, 'Banana'), ('22000000-0000-0000-0000-000000000025', 2, 'Car'),
    ('22000000-0000-0000-0000-000000000026', 0, 'Dog, cat, bird'), ('22000000-0000-0000-0000-000000000026', 1, 'Car, bus, bike'), ('22000000-0000-0000-0000-000000000026', 2, 'Both'),
    ('22000000-0000-0000-0000-000000000027', 0, 'Strawberry'), ('22000000-0000-0000-0000-000000000027', 1, 'Grape'), ('22000000-0000-0000-0000-000000000027', 2, 'Chair'),

    ('22000000-0000-0000-0000-000000000028', 0, 'A'), ('22000000-0000-0000-0000-000000000028', 1, 'M'), ('22000000-0000-0000-0000-000000000028', 2, 'Z'),
    ('22000000-0000-0000-0000-000000000029', 0, 'A'), ('22000000-0000-0000-0000-000000000029', 1, 'B'), ('22000000-0000-0000-0000-000000000029', 2, 'C'),
    ('22000000-0000-0000-0000-000000000030', 0, 'A'), ('22000000-0000-0000-0000-000000000030', 1, 'B'), ('22000000-0000-0000-0000-000000000030', 2, 'M'),

    ('22000000-0000-0000-0000-000000000031', 0, 'X'), ('22000000-0000-0000-0000-000000000031', 1, 'Y'), ('22000000-0000-0000-0000-000000000031', 2, 'Z'),
    ('22000000-0000-0000-0000-000000000032', 0, 'Z'), ('22000000-0000-0000-0000-000000000032', 1, 'N'), ('22000000-0000-0000-0000-000000000032', 2, 'S'),
    ('22000000-0000-0000-0000-000000000033', 0, 'M'), ('22000000-0000-0000-0000-000000000033', 1, 'O'), ('22000000-0000-0000-0000-000000000033', 2, 'P'),

    ('22000000-0000-0000-0000-000000000034', 0, 'B'), ('22000000-0000-0000-0000-000000000034', 1, 'D'), ('22000000-0000-0000-0000-000000000034', 2, 'T'),
    ('22000000-0000-0000-0000-000000000035', 0, 'K'), ('22000000-0000-0000-0000-000000000035', 1, 'S'), ('22000000-0000-0000-0000-000000000035', 2, 'T'),
    ('22000000-0000-0000-0000-000000000036', 0, 'D'), ('22000000-0000-0000-0000-000000000036', 1, 'G'), ('22000000-0000-0000-0000-000000000036', 2, 'B'),

    ('22000000-0000-0000-0000-000000000037', 0, 'Hat'), ('22000000-0000-0000-0000-000000000037', 1, 'Dog'), ('22000000-0000-0000-0000-000000000037', 2, 'Sun'),
    ('22000000-0000-0000-0000-000000000038', 0, 'Tree'), ('22000000-0000-0000-0000-000000000038', 1, 'Tall'), ('22000000-0000-0000-0000-000000000038', 2, 'Cup'),
    ('22000000-0000-0000-0000-000000000039', 0, 'Fun'), ('22000000-0000-0000-0000-000000000039', 1, 'Moon'), ('22000000-0000-0000-0000-000000000039', 2, 'Star'),

    ('22000000-0000-0000-0000-000000000040', 0, 'A duck'), ('22000000-0000-0000-0000-000000000040', 1, 'A cat'), ('22000000-0000-0000-0000-000000000040', 2, 'A boy'),
    ('22000000-0000-0000-0000-000000000041', 0, 'Honey'), ('22000000-0000-0000-0000-000000000041', 1, 'Fish'), ('22000000-0000-0000-0000-000000000041', 2, 'Berries'),
    ('22000000-0000-0000-0000-000000000042', 0, 'A tree'), ('22000000-0000-0000-0000-000000000042', 1, 'A flower'), ('22000000-0000-0000-0000-000000000042', 2, 'A vegetable'),

    ('22000000-0000-0000-0000-000000000043', 0, 'Toothbrush'), ('22000000-0000-0000-0000-000000000043', 1, 'Spoon'), ('22000000-0000-0000-0000-000000000043', 2, 'Hat'),
    ('22000000-0000-0000-0000-000000000044', 0, 'Gloves'), ('22000000-0000-0000-0000-000000000044', 1, 'Shoes'), ('22000000-0000-0000-0000-000000000044', 2, 'Hat'),
    ('22000000-0000-0000-0000-000000000045', 0, 'Water'), ('22000000-0000-0000-0000-000000000045', 1, 'Rocks'), ('22000000-0000-0000-0000-000000000045', 2, 'Paper'),

    ('22000000-0000-0000-0000-000000000046', 0, 'Bat'), ('22000000-0000-0000-0000-000000000046', 1, 'Dog'), ('22000000-0000-0000-0000-000000000046', 2, 'Sun'),
    ('22000000-0000-0000-0000-000000000047', 0, 'Cat'), ('22000000-0000-0000-0000-000000000047', 1, 'Duck'), ('22000000-0000-0000-0000-000000000047', 2, 'Fish'),
    ('22000000-0000-0000-0000-000000000048', 0, 'Sun and Fun'), ('22000000-0000-0000-0000-000000000048', 1, 'Sun and Moon'), ('22000000-0000-0000-0000-000000000048', 2, 'Sun and Star'),

    ('22000000-0000-0000-0000-000000000049', 0, 'Sit down'), ('22000000-0000-0000-0000-000000000049', 1, 'Stand up'), ('22000000-0000-0000-0000-000000000049', 2, 'Clap hands'),
    ('22000000-0000-0000-0000-000000000050', 0, 'Your nose'), ('22000000-0000-0000-0000-000000000050', 1, 'Your toes'), ('22000000-0000-0000-0000-000000000050', 2, 'Your ears'),
    ('22000000-0000-0000-0000-000000000051', 0, 'Your hand'), ('22000000-0000-0000-0000-000000000051', 1, 'Your foot'), ('22000000-0000-0000-0000-000000000051', 2, 'Your voice');
