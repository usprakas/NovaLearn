-- Kindergarten curriculum: 9 Math lessons + 8 English lessons.

INSERT INTO skills (code, subject_code, name) VALUES
    ('COUNT_20', 'MATH', 'Counting to 20'),
    ('COUNT_100_10S', 'MATH', 'Counting to 100 by Tens'),
    ('WRITE_NUM', 'MATH', 'Writing Numbers'),
    ('ADD_5', 'MATH', 'Addition within 5'),
    ('SUB_5', 'MATH', 'Subtraction within 5'),
    ('COMPARE_K', 'MATH', 'More, Less, or Equal'),
    ('SHAPES_K', 'MATH', '2D Shapes'),
    ('MEASURE_K', 'MATH', 'Longer, Shorter, Taller'),
    ('PATTERNS_K', 'MATH', 'AB and ABC Patterns'),
    ('SIGHT_WORDS_K', 'ENGLISH', 'Sight Words'),
    ('LETTER_SOUNDS_K', 'ENGLISH', 'All Letter Sounds'),
    ('CVC_WORDS', 'ENGLISH', 'Simple Three-Letter Words'),
    ('RHYMING_K', 'ENGLISH', 'Rhyming Words'),
    ('SEQUENCING_K', 'ENGLISH', 'What Happened First?'),
    ('BEGIN_END_SOUNDS', 'ENGLISH', 'Beginning and Ending Sounds'),
    ('SIMPLE_SENTENCES', 'ENGLISH', 'Reading Simple Sentences'),
    ('NOUNS_K', 'ENGLISH', 'Naming Words');

INSERT INTO lessons (id, code, subject_code, grade_level, display_order, title, description) VALUES
    ('13000000-0000-0000-0000-000000000001', 'K-COUNT-01', 'MATH', 'KINDERGARTEN', 1, 'Counting to 20', 'Count forward and find what number comes next.'),
    ('13000000-0000-0000-0000-000000000002', 'K-COUNT100-01', 'MATH', 'KINDERGARTEN', 2, 'Counting to 100 by Tens', 'Skip count by tens all the way to 100.'),
    ('13000000-0000-0000-0000-000000000003', 'K-WRITE-01', 'MATH', 'KINDERGARTEN', 3, 'Writing Numbers 0 to 20', 'Match number words to the numbers they name.'),
    ('13000000-0000-0000-0000-000000000004', 'K-ADD5-01', 'MATH', 'KINDERGARTEN', 4, 'Addition within 5', 'Add two small numbers together.'),
    ('13000000-0000-0000-0000-000000000005', 'K-SUB5-01', 'MATH', 'KINDERGARTEN', 5, 'Subtraction within 5', 'Take away a small number from another.'),
    ('13000000-0000-0000-0000-000000000006', 'K-COMPARE-01', 'MATH', 'KINDERGARTEN', 6, 'More, Less, or Equal', 'Compare the size of two groups.'),
    ('13000000-0000-0000-0000-000000000007', 'K-SHAPE-01', 'MATH', 'KINDERGARTEN', 7, '2D Shapes', 'Identify shapes by their sides and corners.'),
    ('13000000-0000-0000-0000-000000000008', 'K-MEASURE-01', 'MATH', 'KINDERGARTEN', 8, 'Longer, Shorter, Taller', 'Compare the length or height of two things.'),
    ('13000000-0000-0000-0000-000000000009', 'K-PATTERN-01', 'MATH', 'KINDERGARTEN', 9, 'AB and ABC Patterns', 'Find what comes next in a repeating pattern.'),
    ('13000000-0000-0000-0000-000000000010', 'K-ENG-SIGHT-01', 'ENGLISH', 'KINDERGARTEN', 1, 'Sight Words', 'Recognize common words by sight.'),
    ('13000000-0000-0000-0000-000000000011', 'K-ENG-SOUNDS-01', 'ENGLISH', 'KINDERGARTEN', 2, 'All Letter Sounds', 'Match every letter to the sound it makes.'),
    ('13000000-0000-0000-0000-000000000012', 'K-ENG-CVC-01', 'ENGLISH', 'KINDERGARTEN', 3, 'Simple Three-Letter Words', 'Sound out short consonant-vowel-consonant words.'),
    ('13000000-0000-0000-0000-000000000013', 'K-ENG-RHYME-01', 'ENGLISH', 'KINDERGARTEN', 4, 'Rhyming Words', 'Find words that end with the same sound.'),
    ('13000000-0000-0000-0000-000000000014', 'K-ENG-SEQUENCE-01', 'ENGLISH', 'KINDERGARTEN', 5, 'What Happened First?', 'Put story events in the right order.'),
    ('13000000-0000-0000-0000-000000000015', 'K-ENG-BEGINEND-01', 'ENGLISH', 'KINDERGARTEN', 6, 'Beginning and Ending Sounds', 'Hear the first and last sounds in a word.'),
    ('13000000-0000-0000-0000-000000000016', 'K-ENG-SENTENCE-01', 'ENGLISH', 'KINDERGARTEN', 7, 'Reading Simple Sentences', 'Read a short sentence and answer a question about it.'),
    ('13000000-0000-0000-0000-000000000017', 'K-ENG-NOUNS-01', 'ENGLISH', 'KINDERGARTEN', 8, 'Naming Words', 'Find the word that names a person, place, or thing.');

INSERT INTO exercises (id, lesson_code, skill_code, display_order, prompt, answer_index, explanation, hint) VALUES
    ('23000000-0000-0000-0000-000000000001', 'K-COUNT-01', 'COUNT_20', 1, 'What number comes after 14?', 1, 'After 14 comes 15.', 'Count up one from 14.'),
    ('23000000-0000-0000-0000-000000000002', 'K-COUNT-01', 'COUNT_20', 2, 'What number comes before 20?', 1, 'Before 20 comes 19.', 'Count down one from 20.'),
    ('23000000-0000-0000-0000-000000000003', 'K-COUNT-01', 'COUNT_20', 3, 'Count up: 16, 17, 18, __?', 0, 'After 18 comes 19.', 'Keep counting up by one.'),

    ('23000000-0000-0000-0000-000000000004', 'K-COUNT100-01', 'COUNT_100_10S', 1, 'Count by tens: 10, 20, 30, __?', 1, 'After 30, counting by tens, comes 40.', 'Add ten each time.'),
    ('23000000-0000-0000-0000-000000000005', 'K-COUNT100-01', 'COUNT_100_10S', 2, 'Count by tens: 50, 60, 70, __?', 1, 'After 70, counting by tens, comes 80.', 'Add ten each time.'),
    ('23000000-0000-0000-0000-000000000006', 'K-COUNT100-01', 'COUNT_100_10S', 3, 'What number comes after 90 when counting by tens?', 1, 'After 90, counting by tens, comes 100.', 'Add ten more to 90.'),

    ('23000000-0000-0000-0000-000000000007', 'K-WRITE-01', 'WRITE_NUM', 1, 'Which number is written as "twelve"?', 1, '"Twelve" is the word for the number 12.', 'Think about counting past ten.'),
    ('23000000-0000-0000-0000-000000000008', 'K-WRITE-01', 'WRITE_NUM', 2, 'Which number is written as "seven"?', 1, '"Seven" is the word for the number 7.', 'Count on your fingers up to this word.'),
    ('23000000-0000-0000-0000-000000000009', 'K-WRITE-01', 'WRITE_NUM', 3, 'Which number is written as "eighteen"?', 1, '"Eighteen" is the word for the number 18.', 'Think about counting close to twenty.'),

    ('23000000-0000-0000-0000-000000000010', 'K-ADD5-01', 'ADD_5', 1, 'What is 2 + 1?', 1, '2 + 1 = 3.', 'Count one more after 2.'),
    ('23000000-0000-0000-0000-000000000011', 'K-ADD5-01', 'ADD_5', 2, 'What is 1 + 3?', 1, '1 + 3 = 4.', 'Count three more after 1.'),
    ('23000000-0000-0000-0000-000000000012', 'K-ADD5-01', 'ADD_5', 3, 'What is 2 + 2?', 1, '2 + 2 = 4.', 'Try using your fingers: 2 and 2 more.'),

    ('23000000-0000-0000-0000-000000000013', 'K-SUB5-01', 'SUB_5', 1, 'What is 4 - 1?', 1, '4 - 1 = 3.', 'Count back one from 4.'),
    ('23000000-0000-0000-0000-000000000014', 'K-SUB5-01', 'SUB_5', 2, 'What is 5 - 2?', 1, '5 - 2 = 3.', 'Count back two from 5.'),
    ('23000000-0000-0000-0000-000000000015', 'K-SUB5-01', 'SUB_5', 3, 'What is 3 - 1?', 1, '3 - 1 = 2.', 'Count back one from 3.'),

    ('23000000-0000-0000-0000-000000000016', 'K-COMPARE-01', 'COMPARE_K', 1, 'Which group has more: 3 apples or 5 apples?', 1, '5 apples is more than 3 apples.', 'Count each group and compare.'),
    ('23000000-0000-0000-0000-000000000017', 'K-COMPARE-01', 'COMPARE_K', 2, 'Which group has less: 7 stars or 2 stars?', 1, '2 stars is less than 7 stars.', 'Count each group and compare.'),
    ('23000000-0000-0000-0000-000000000018', 'K-COMPARE-01', 'COMPARE_K', 3, 'Are 4 balls and 4 balls equal groups?', 0, 'Both groups have 4, so they are equal.', 'Count both groups and see if they match.'),

    ('23000000-0000-0000-0000-000000000019', 'K-SHAPE-01', 'SHAPES_K', 1, 'Which shape has 5 sides?', 0, 'A pentagon has 5 sides.', 'Think of a shape like a house''s front wall with a pointy roof.'),
    ('23000000-0000-0000-0000-000000000020', 'K-SHAPE-01', 'SHAPES_K', 2, 'Which shape has no corners?', 1, 'A circle has no corners — it is perfectly round.', 'Think of a shape with no straight lines at all.'),
    ('23000000-0000-0000-0000-000000000021', 'K-SHAPE-01', 'SHAPES_K', 3, 'Which shape looks like a door?', 0, 'A rectangle looks like a door.', 'Think of a shape that is taller than it is wide, with 4 corners.'),

    ('23000000-0000-0000-0000-000000000022', 'K-MEASURE-01', 'MEASURE_K', 1, 'A snake and a worm. Which is usually longer?', 0, 'A snake is usually longer than a worm.', 'Picture the two animals stretched out side by side.'),
    ('23000000-0000-0000-0000-000000000023', 'K-MEASURE-01', 'MEASURE_K', 2, 'A giraffe and a dog. Which is usually taller?', 0, 'A giraffe is usually much taller than a dog.', 'Picture the two animals standing side by side.'),
    ('23000000-0000-0000-0000-000000000024', 'K-MEASURE-01', 'MEASURE_K', 3, 'Two pencils, one broken in half. Which piece is shorter?', 1, 'The broken half is shorter than the whole pencil.', 'Think about what breaking something in half does to its length.'),

    ('23000000-0000-0000-0000-000000000025', 'K-PATTERN-01', 'PATTERNS_K', 1, 'What comes next: circle, square, circle, square, __?', 0, 'The pattern alternates circle and square, so circle comes next.', 'The pattern repeats every two shapes.'),
    ('23000000-0000-0000-0000-000000000026', 'K-PATTERN-01', 'PATTERNS_K', 2, 'What comes next: red, yellow, blue, red, yellow, __?', 2, 'The pattern repeats every three colors, so blue comes next.', 'The pattern repeats every three colors.'),
    ('23000000-0000-0000-0000-000000000027', 'K-PATTERN-01', 'PATTERNS_K', 3, 'What comes next: 1, 2, 1, 2, 1, __?', 1, 'The pattern alternates 1 and 2, so 2 comes next.', 'The pattern repeats every two numbers.'),

    ('23000000-0000-0000-0000-000000000028', 'K-ENG-SIGHT-01', 'SIGHT_WORDS_K', 1, 'Which word is "the"?', 0, 'The first choice spells "the."', 'Look for the three letters t-h-e.'),
    ('23000000-0000-0000-0000-000000000029', 'K-ENG-SIGHT-01', 'SIGHT_WORDS_K', 2, 'Which word is "see"?', 1, 'The second choice spells "see."', 'Look for the letters s-e-e.'),
    ('23000000-0000-0000-0000-000000000030', 'K-ENG-SIGHT-01', 'SIGHT_WORDS_K', 3, 'Which word is "like"?', 1, 'The second choice spells "like."', 'Look for the letters l-i-k-e.'),

    ('23000000-0000-0000-0000-000000000031', 'K-ENG-SOUNDS-01', 'LETTER_SOUNDS_K', 1, 'What sound does the letter "M" make?', 0, 'The letter M makes the "mmm" sound.', 'Say the letter name and listen to the sound it starts with.'),
    ('23000000-0000-0000-0000-000000000032', 'K-ENG-SOUNDS-01', 'LETTER_SOUNDS_K', 2, 'What sound does the letter "S" make?', 1, 'The letter S makes the "sss" sound.', 'Say the letter name and listen to the sound it starts with.'),
    ('23000000-0000-0000-0000-000000000033', 'K-ENG-SOUNDS-01', 'LETTER_SOUNDS_K', 3, 'What sound does the letter "P" make?', 0, 'The letter P makes the "puh" sound.', 'Say the letter name and listen to the sound it starts with.'),

    ('23000000-0000-0000-0000-000000000034', 'K-ENG-CVC-01', 'CVC_WORDS', 1, 'What word is spelled C-A-T?', 0, 'C-A-T spells "cat."', 'Sound out each letter: cuh-a-tuh.'),
    ('23000000-0000-0000-0000-000000000035', 'K-ENG-CVC-01', 'CVC_WORDS', 2, 'What word is spelled S-U-N?', 0, 'S-U-N spells "sun."', 'Sound out each letter: sss-uh-n.'),
    ('23000000-0000-0000-0000-000000000036', 'K-ENG-CVC-01', 'CVC_WORDS', 3, 'What word is spelled D-O-G?', 1, 'D-O-G spells "dog."', 'Sound out each letter: duh-o-guh.'),

    ('23000000-0000-0000-0000-000000000037', 'K-ENG-RHYME-01', 'RHYMING_K', 1, 'Which word rhymes with "pig"?', 0, '"Big" rhymes with "pig" — they both end in "ig".', 'Rhyming words end with the same sound.'),
    ('23000000-0000-0000-0000-000000000038', 'K-ENG-RHYME-01', 'RHYMING_K', 2, 'Which word rhymes with "hop"?', 1, '"Top" rhymes with "hop" — they both end in "op".', 'Rhyming words end with the same sound.'),
    ('23000000-0000-0000-0000-000000000039', 'K-ENG-RHYME-01', 'RHYMING_K', 3, 'Which word rhymes with "bed"?', 0, '"Red" rhymes with "bed" — they both end in "ed".', 'Rhyming words end with the same sound.'),

    ('23000000-0000-0000-0000-000000000040', 'K-ENG-SEQUENCE-01', 'SEQUENCING_K', 1, 'First the egg cracked, then a chick came out. What happened first?', 0, 'The egg cracking happened before the chick came out.', 'Look for the word "first" in the sentence.'),
    ('23000000-0000-0000-0000-000000000041', 'K-ENG-SEQUENCE-01', 'SEQUENCING_K', 2, 'Tom woke up, then he ate breakfast. What happened second?', 1, 'Eating breakfast happened after waking up.', 'Look for the word "then" in the sentence.'),
    ('23000000-0000-0000-0000-000000000042', 'K-ENG-SEQUENCE-01', 'SEQUENCING_K', 3, 'The seed was planted, then it grew into a plant. What happened last?', 1, 'Growing into a plant happened after the seed was planted.', 'Look for which event comes after "then".'),

    ('23000000-0000-0000-0000-000000000043', 'K-ENG-BEGINEND-01', 'BEGIN_END_SOUNDS', 1, 'What is the beginning sound in "fish"?', 0, '"Fish" begins with the F sound.', 'Say the word slowly and listen to the very first sound.'),
    ('23000000-0000-0000-0000-000000000044', 'K-ENG-BEGINEND-01', 'BEGIN_END_SOUNDS', 2, 'What is the ending sound in "cup"?', 2, '"Cup" ends with the P sound.', 'Say the word slowly and listen to the very last sound.'),
    ('23000000-0000-0000-0000-000000000045', 'K-ENG-BEGINEND-01', 'BEGIN_END_SOUNDS', 3, 'What is the beginning sound in "run"?', 0, '"Run" begins with the R sound.', 'Say the word slowly and listen to the very first sound.'),

    ('23000000-0000-0000-0000-000000000046', 'K-ENG-SENTENCE-01', 'SIMPLE_SENTENCES', 1, 'Read: "I see a cat." What does the person see?', 1, 'The sentence says "I see a cat," so the answer is a cat.', 'Look for the word right after "see".'),
    ('23000000-0000-0000-0000-000000000047', 'K-ENG-SENTENCE-01', 'SIMPLE_SENTENCES', 2, 'Read: "The sun is hot." What is hot?', 0, 'The sentence says the sun is hot.', 'Look for the word right before "is hot".'),
    ('23000000-0000-0000-0000-000000000048', 'K-ENG-SENTENCE-01', 'SIMPLE_SENTENCES', 3, 'Read: "We run and play." What are "we" doing?', 2, 'The sentence says "we" are running and playing.', 'Look for the action words in the sentence.'),

    ('23000000-0000-0000-0000-000000000049', 'K-ENG-NOUNS-01', 'NOUNS_K', 1, 'Which word names a person, place, or thing?', 1, '"Dog" names a thing, so it is a naming word.', 'A naming word tells you who or what something is.'),
    ('23000000-0000-0000-0000-000000000050', 'K-ENG-NOUNS-01', 'NOUNS_K', 2, 'Which word is a naming word in "The ball is red"?', 0, '"Ball" names a thing, so it is the naming word.', 'A naming word tells you who or what something is.'),
    ('23000000-0000-0000-0000-000000000051', 'K-ENG-NOUNS-01', 'NOUNS_K', 3, 'Which of these is a naming word?', 2, '"School" names a place, so it is a naming word.', 'A naming word can name a person, a place, or a thing.');

INSERT INTO exercise_choices (exercise_id, choice_index, choice_text) VALUES
    ('23000000-0000-0000-0000-000000000001', 0, '13'), ('23000000-0000-0000-0000-000000000001', 1, '15'), ('23000000-0000-0000-0000-000000000001', 2, '16'),
    ('23000000-0000-0000-0000-000000000002', 0, '18'), ('23000000-0000-0000-0000-000000000002', 1, '19'), ('23000000-0000-0000-0000-000000000002', 2, '21'),
    ('23000000-0000-0000-0000-000000000003', 0, '19'), ('23000000-0000-0000-0000-000000000003', 1, '20'), ('23000000-0000-0000-0000-000000000003', 2, '17'),

    ('23000000-0000-0000-0000-000000000004', 0, '35'), ('23000000-0000-0000-0000-000000000004', 1, '40'), ('23000000-0000-0000-0000-000000000004', 2, '45'),
    ('23000000-0000-0000-0000-000000000005', 0, '75'), ('23000000-0000-0000-0000-000000000005', 1, '80'), ('23000000-0000-0000-0000-000000000005', 2, '85'),
    ('23000000-0000-0000-0000-000000000006', 0, '95'), ('23000000-0000-0000-0000-000000000006', 1, '100'), ('23000000-0000-0000-0000-000000000006', 2, '110'),

    ('23000000-0000-0000-0000-000000000007', 0, '10'), ('23000000-0000-0000-0000-000000000007', 1, '12'), ('23000000-0000-0000-0000-000000000007', 2, '20'),
    ('23000000-0000-0000-0000-000000000008', 0, '6'), ('23000000-0000-0000-0000-000000000008', 1, '7'), ('23000000-0000-0000-0000-000000000008', 2, '9'),
    ('23000000-0000-0000-0000-000000000009', 0, '8'), ('23000000-0000-0000-0000-000000000009', 1, '18'), ('23000000-0000-0000-0000-000000000009', 2, '80'),

    ('23000000-0000-0000-0000-000000000010', 0, '2'), ('23000000-0000-0000-0000-000000000010', 1, '3'), ('23000000-0000-0000-0000-000000000010', 2, '4'),
    ('23000000-0000-0000-0000-000000000011', 0, '3'), ('23000000-0000-0000-0000-000000000011', 1, '4'), ('23000000-0000-0000-0000-000000000011', 2, '5'),
    ('23000000-0000-0000-0000-000000000012', 0, '3'), ('23000000-0000-0000-0000-000000000012', 1, '4'), ('23000000-0000-0000-0000-000000000012', 2, '5'),

    ('23000000-0000-0000-0000-000000000013', 0, '2'), ('23000000-0000-0000-0000-000000000013', 1, '3'), ('23000000-0000-0000-0000-000000000013', 2, '4'),
    ('23000000-0000-0000-0000-000000000014', 0, '2'), ('23000000-0000-0000-0000-000000000014', 1, '3'), ('23000000-0000-0000-0000-000000000014', 2, '4'),
    ('23000000-0000-0000-0000-000000000015', 0, '1'), ('23000000-0000-0000-0000-000000000015', 1, '2'), ('23000000-0000-0000-0000-000000000015', 2, '3'),

    ('23000000-0000-0000-0000-000000000016', 0, '3 apples'), ('23000000-0000-0000-0000-000000000016', 1, '5 apples'), ('23000000-0000-0000-0000-000000000016', 2, 'Same'),
    ('23000000-0000-0000-0000-000000000017', 0, '7 stars'), ('23000000-0000-0000-0000-000000000017', 1, '2 stars'), ('23000000-0000-0000-0000-000000000017', 2, 'Same'),
    ('23000000-0000-0000-0000-000000000018', 0, 'Yes'), ('23000000-0000-0000-0000-000000000018', 1, 'No'), ('23000000-0000-0000-0000-000000000018', 2, 'Can''t tell'),

    ('23000000-0000-0000-0000-000000000019', 0, 'Pentagon'), ('23000000-0000-0000-0000-000000000019', 1, 'Square'), ('23000000-0000-0000-0000-000000000019', 2, 'Circle'),
    ('23000000-0000-0000-0000-000000000020', 0, 'Triangle'), ('23000000-0000-0000-0000-000000000020', 1, 'Circle'), ('23000000-0000-0000-0000-000000000020', 2, 'Rectangle'),
    ('23000000-0000-0000-0000-000000000021', 0, 'Rectangle'), ('23000000-0000-0000-0000-000000000021', 1, 'Circle'), ('23000000-0000-0000-0000-000000000021', 2, 'Triangle'),

    ('23000000-0000-0000-0000-000000000022', 0, 'Snake'), ('23000000-0000-0000-0000-000000000022', 1, 'Worm'), ('23000000-0000-0000-0000-000000000022', 2, 'Same'),
    ('23000000-0000-0000-0000-000000000023', 0, 'Giraffe'), ('23000000-0000-0000-0000-000000000023', 1, 'Dog'), ('23000000-0000-0000-0000-000000000023', 2, 'Same'),
    ('23000000-0000-0000-0000-000000000024', 0, 'The whole pencil'), ('23000000-0000-0000-0000-000000000024', 1, 'The broken half'), ('23000000-0000-0000-0000-000000000024', 2, 'Same'),

    ('23000000-0000-0000-0000-000000000025', 0, 'circle'), ('23000000-0000-0000-0000-000000000025', 1, 'square'), ('23000000-0000-0000-0000-000000000025', 2, 'triangle'),
    ('23000000-0000-0000-0000-000000000026', 0, 'red'), ('23000000-0000-0000-0000-000000000026', 1, 'yellow'), ('23000000-0000-0000-0000-000000000026', 2, 'blue'),
    ('23000000-0000-0000-0000-000000000027', 0, '1'), ('23000000-0000-0000-0000-000000000027', 1, '2'), ('23000000-0000-0000-0000-000000000027', 2, '3'),

    ('23000000-0000-0000-0000-000000000028', 0, 'the'), ('23000000-0000-0000-0000-000000000028', 1, 'and'), ('23000000-0000-0000-0000-000000000028', 2, 'cat'),
    ('23000000-0000-0000-0000-000000000029', 0, 'sat'), ('23000000-0000-0000-0000-000000000029', 1, 'see'), ('23000000-0000-0000-0000-000000000029', 2, 'sun'),
    ('23000000-0000-0000-0000-000000000030', 0, 'look'), ('23000000-0000-0000-0000-000000000030', 1, 'like'), ('23000000-0000-0000-0000-000000000030', 2, 'lake'),

    ('23000000-0000-0000-0000-000000000031', 0, 'Mmm'), ('23000000-0000-0000-0000-000000000031', 1, 'Sss'), ('23000000-0000-0000-0000-000000000031', 2, 'Ttt'),
    ('23000000-0000-0000-0000-000000000032', 0, 'Mmm'), ('23000000-0000-0000-0000-000000000032', 1, 'Sss'), ('23000000-0000-0000-0000-000000000032', 2, 'Ttt'),
    ('23000000-0000-0000-0000-000000000033', 0, 'Puh'), ('23000000-0000-0000-0000-000000000033', 1, 'Buh'), ('23000000-0000-0000-0000-000000000033', 2, 'Duh'),

    ('23000000-0000-0000-0000-000000000034', 0, 'cat'), ('23000000-0000-0000-0000-000000000034', 1, 'cot'), ('23000000-0000-0000-0000-000000000034', 2, 'cut'),
    ('23000000-0000-0000-0000-000000000035', 0, 'sun'), ('23000000-0000-0000-0000-000000000035', 1, 'sin'), ('23000000-0000-0000-0000-000000000035', 2, 'son'),
    ('23000000-0000-0000-0000-000000000036', 0, 'dig'), ('23000000-0000-0000-0000-000000000036', 1, 'dog'), ('23000000-0000-0000-0000-000000000036', 2, 'dug'),

    ('23000000-0000-0000-0000-000000000037', 0, 'big'), ('23000000-0000-0000-0000-000000000037', 1, 'dog'), ('23000000-0000-0000-0000-000000000037', 2, 'cup'),
    ('23000000-0000-0000-0000-000000000038', 0, 'hat'), ('23000000-0000-0000-0000-000000000038', 1, 'top'), ('23000000-0000-0000-0000-000000000038', 2, 'run'),
    ('23000000-0000-0000-0000-000000000039', 0, 'red'), ('23000000-0000-0000-0000-000000000039', 1, 'big'), ('23000000-0000-0000-0000-000000000039', 2, 'cup'),

    ('23000000-0000-0000-0000-000000000040', 0, 'The egg cracked'), ('23000000-0000-0000-0000-000000000040', 1, 'The chick came out'), ('23000000-0000-0000-0000-000000000040', 2, 'Neither'),
    ('23000000-0000-0000-0000-000000000041', 0, 'Tom woke up'), ('23000000-0000-0000-0000-000000000041', 1, 'Tom ate breakfast'), ('23000000-0000-0000-0000-000000000041', 2, 'Both at once'),
    ('23000000-0000-0000-0000-000000000042', 0, 'It was planted'), ('23000000-0000-0000-0000-000000000042', 1, 'It grew into a plant'), ('23000000-0000-0000-0000-000000000042', 2, 'Nothing'),

    ('23000000-0000-0000-0000-000000000043', 0, 'F'), ('23000000-0000-0000-0000-000000000043', 1, 'Sh'), ('23000000-0000-0000-0000-000000000043', 2, 'Ih'),
    ('23000000-0000-0000-0000-000000000044', 0, 'Kuh'), ('23000000-0000-0000-0000-000000000044', 1, 'Uh'), ('23000000-0000-0000-0000-000000000044', 2, 'Puh'),
    ('23000000-0000-0000-0000-000000000045', 0, 'R'), ('23000000-0000-0000-0000-000000000045', 1, 'U'), ('23000000-0000-0000-0000-000000000045', 2, 'N'),

    ('23000000-0000-0000-0000-000000000046', 0, 'A dog'), ('23000000-0000-0000-0000-000000000046', 1, 'A cat'), ('23000000-0000-0000-0000-000000000046', 2, 'A bird'),
    ('23000000-0000-0000-0000-000000000047', 0, 'The sun'), ('23000000-0000-0000-0000-000000000047', 1, 'The moon'), ('23000000-0000-0000-0000-000000000047', 2, 'The rain'),
    ('23000000-0000-0000-0000-000000000048', 0, 'Sleeping'), ('23000000-0000-0000-0000-000000000048', 1, 'Eating'), ('23000000-0000-0000-0000-000000000048', 2, 'Running and playing'),

    ('23000000-0000-0000-0000-000000000049', 0, 'jump'), ('23000000-0000-0000-0000-000000000049', 1, 'dog'), ('23000000-0000-0000-0000-000000000049', 2, 'fast'),
    ('23000000-0000-0000-0000-000000000050', 0, 'ball'), ('23000000-0000-0000-0000-000000000050', 1, 'is'), ('23000000-0000-0000-0000-000000000050', 2, 'red'),
    ('23000000-0000-0000-0000-000000000051', 0, 'happy'), ('23000000-0000-0000-0000-000000000051', 1, 'run'), ('23000000-0000-0000-0000-000000000051', 2, 'school');
