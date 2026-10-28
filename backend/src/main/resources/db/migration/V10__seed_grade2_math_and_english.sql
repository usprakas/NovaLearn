-- Grade 2 curriculum: 9 Math lessons + 8 English lessons, the first full grade-level content
-- batch built on top of the V9 grade-filtering schema change. Skill codes are grade-specific
-- (e.g. ADD_100 rather than reusing Grade 1's ADDITION) so per-skill accuracy tracking
-- (skill_progress) doesn't conflate different difficulty levels under one bucket.

INSERT INTO skills (code, subject_code, name) VALUES
    ('ADD_100', 'MATH', 'Addition within 100'),
    ('SUB_100', 'MATH', 'Subtraction within 100'),
    ('PLACE_VALUE', 'MATH', 'Place Value'),
    ('SKIP_COUNT', 'MATH', 'Skip Counting'),
    ('TELL_TIME', 'MATH', 'Telling Time'),
    ('MONEY', 'MATH', 'Counting Money'),
    ('MEASURE_LEN', 'MATH', 'Measuring Length'),
    ('SHAPES_G2', 'MATH', '2D and 3D Shapes'),
    ('WORD_PROB_G2', 'MATH', 'Two-Step Word Problems'),
    ('COMPREHENSION_G2', 'ENGLISH', 'Reading Comprehension'),
    ('COMPOUND_WORDS', 'ENGLISH', 'Compound Words'),
    ('CONTRACTIONS', 'ENGLISH', 'Contractions'),
    ('SYNONYMS_ANTONYMS', 'ENGLISH', 'Synonyms and Antonyms'),
    ('PARTS_OF_SPEECH_G2', 'ENGLISH', 'Nouns, Verbs, and Adjectives'),
    ('PLURALS', 'ENGLISH', 'Plurals'),
    ('SENTENCE_TYPES', 'ENGLISH', 'Types of Sentences'),
    ('MAIN_IDEA', 'ENGLISH', 'Finding the Main Idea');

INSERT INTO lessons (id, code, subject_code, grade_level, display_order, title, description) VALUES
    ('11000000-0000-0000-0000-000000000001', 'G2-ADD-01', 'MATH', 'GRADE_2', 1, 'Adding within 100', 'Add two-digit numbers using tens and ones.'),
    ('11000000-0000-0000-0000-000000000002', 'G2-SUB-01', 'MATH', 'GRADE_2', 2, 'Subtracting within 100', 'Subtract two-digit numbers using tens and ones.'),
    ('11000000-0000-0000-0000-000000000003', 'G2-PLACE-01', 'MATH', 'GRADE_2', 3, 'Place Value: Tens and Ones', 'Understand what each digit in a two-digit number means.'),
    ('11000000-0000-0000-0000-000000000004', 'G2-SKIP-01', 'MATH', 'GRADE_2', 4, 'Skip Counting by 2s, 5s, and 10s', 'Count forward by groups instead of one at a time.'),
    ('11000000-0000-0000-0000-000000000005', 'G2-TIME-01', 'MATH', 'GRADE_2', 5, 'Telling Time to the Hour and Half-Hour', 'Read a clock''s hands to tell the time.'),
    ('11000000-0000-0000-0000-000000000006', 'G2-MONEY-01', 'MATH', 'GRADE_2', 6, 'Counting Money', 'Identify coins and add up their value.'),
    ('11000000-0000-0000-0000-000000000007', 'G2-MEASURE-01', 'MATH', 'GRADE_2', 7, 'Measuring Length', 'Measure and compare the length of objects.'),
    ('11000000-0000-0000-0000-000000000008', 'G2-SHAPE-01', 'MATH', 'GRADE_2', 8, '2D and 3D Shapes', 'Identify flat and solid shapes by their sides and corners.'),
    ('11000000-0000-0000-0000-000000000009', 'G2-WORD-01', 'MATH', 'GRADE_2', 9, 'Two-Step Word Problems', 'Solve problems that take two steps to answer.'),
    ('11000000-0000-0000-0000-000000000010', 'G2-ENG-COMP-01', 'ENGLISH', 'GRADE_2', 1, 'Reading Comprehension', 'Read a short passage and answer questions about it.'),
    ('11000000-0000-0000-0000-000000000011', 'G2-ENG-COMPOUND-01', 'ENGLISH', 'GRADE_2', 2, 'Compound Words', 'Combine two small words into one bigger word.'),
    ('11000000-0000-0000-0000-000000000012', 'G2-ENG-CONTRACT-01', 'ENGLISH', 'GRADE_2', 3, 'Contractions', 'Join two words together with an apostrophe.'),
    ('11000000-0000-0000-0000-000000000013', 'G2-ENG-SYNANT-01', 'ENGLISH', 'GRADE_2', 4, 'Synonyms and Antonyms', 'Find words that mean the same or the opposite.'),
    ('11000000-0000-0000-0000-000000000014', 'G2-ENG-POS-01', 'ENGLISH', 'GRADE_2', 5, 'Nouns, Verbs, and Adjectives', 'Spot the naming words, action words, and describing words in a sentence.'),
    ('11000000-0000-0000-0000-000000000015', 'G2-ENG-PLURAL-01', 'ENGLISH', 'GRADE_2', 6, 'Plurals', 'Turn one thing into many by changing the word''s ending.'),
    ('11000000-0000-0000-0000-000000000016', 'G2-ENG-SENTTYPE-01', 'ENGLISH', 'GRADE_2', 7, 'Types of Sentences', 'Tell the difference between statements, questions, and exclamations.'),
    ('11000000-0000-0000-0000-000000000017', 'G2-ENG-MAINIDEA-01', 'ENGLISH', 'GRADE_2', 8, 'Finding the Main Idea', 'Figure out what a short passage is mostly about.');

INSERT INTO exercises (id, lesson_code, skill_code, display_order, prompt, answer_index, explanation, hint) VALUES
    ('21000000-0000-0000-0000-000000000001', 'G2-ADD-01', 'ADD_100', 1, 'What is 23 + 15?', 0, '23 + 15 = 38: add the ones (3 + 5 = 8), then the tens (20 + 10 = 30), and combine: 30 + 8 = 38.', 'Add the ones first, then add the tens.'),
    ('21000000-0000-0000-0000-000000000002', 'G2-ADD-01', 'ADD_100', 2, 'Sam has 45 marbles. He gets 30 more. How many does he have now?', 1, '45 + 30 = 75.', 'Add the tens first: 40 + 30 = 70, then add the 5 ones.'),
    ('21000000-0000-0000-0000-000000000003', 'G2-ADD-01', 'ADD_100', 3, 'What is 58 + 24?', 1, '58 + 24 = 82.', 'Add the ones (8 + 4 = 12) and carry the 1 into the tens.'),

    ('21000000-0000-0000-0000-000000000004', 'G2-SUB-01', 'SUB_100', 1, 'What is 56 - 23?', 0, '56 - 23 = 33.', 'Subtract the ones first, then the tens.'),
    ('21000000-0000-0000-0000-000000000005', 'G2-SUB-01', 'SUB_100', 2, 'Mia had 80 stickers. She gave away 35. How many are left?', 0, '80 - 35 = 45.', 'Try subtracting 30 first, then 5 more.'),
    ('21000000-0000-0000-0000-000000000006', 'G2-SUB-01', 'SUB_100', 3, 'What is 90 - 47?', 0, '90 - 47 = 43.', 'Subtract 40 first, then 7 more.'),

    ('21000000-0000-0000-0000-000000000007', 'G2-PLACE-01', 'PLACE_VALUE', 1, 'In the number 47, how many tens are there?', 0, '47 has 4 tens and 7 ones.', 'The first digit tells you the tens.'),
    ('21000000-0000-0000-0000-000000000008', 'G2-PLACE-01', 'PLACE_VALUE', 2, 'What number has 6 tens and 3 ones?', 1, '6 tens and 3 ones makes 63.', 'Tens come first, then ones.'),
    ('21000000-0000-0000-0000-000000000009', 'G2-PLACE-01', 'PLACE_VALUE', 3, 'In the number 82, how many ones are there?', 1, '82 has 8 tens and 2 ones.', 'The second digit tells you the ones.'),

    ('21000000-0000-0000-0000-000000000010', 'G2-SKIP-01', 'SKIP_COUNT', 1, 'Count by 2s: 2, 4, 6, __?', 1, 'Counting by 2s, after 6 comes 8.', 'Add 2 each time.'),
    ('21000000-0000-0000-0000-000000000011', 'G2-SKIP-01', 'SKIP_COUNT', 2, 'Count by 5s: 5, 10, 15, __?', 0, 'Counting by 5s, after 15 comes 20.', 'Add 5 each time.'),
    ('21000000-0000-0000-0000-000000000012', 'G2-SKIP-01', 'SKIP_COUNT', 3, 'Count by 10s: 10, 20, 30, __?', 1, 'Counting by 10s, after 30 comes 40.', 'Add 10 each time.'),

    ('21000000-0000-0000-0000-000000000013', 'G2-TIME-01', 'TELL_TIME', 1, 'The clock''s short hand is on 3 and the long hand is on 12. What time is it?', 0, 'When the long hand points to 12, it is exactly on the hour shown by the short hand: 3:00.', 'The long hand on 12 means it''s exactly on the hour.'),
    ('21000000-0000-0000-0000-000000000014', 'G2-TIME-01', 'TELL_TIME', 2, 'The long hand is on 6, and the short hand is between 7 and 8. What time is it?', 0, 'The long hand on 6 means half past the hour: 7:30.', 'The long hand on 6 always means "half past."'),
    ('21000000-0000-0000-0000-000000000015', 'G2-TIME-01', 'TELL_TIME', 3, 'What time comes right after 4:00?', 0, 'Half an hour after 4:00 is 4:30.', 'Think about what "half past" the hour looks like.'),

    ('21000000-0000-0000-0000-000000000016', 'G2-MONEY-01', 'MONEY', 1, 'A nickel is worth how many cents?', 1, 'A nickel is worth 5 cents.', 'A nickel is the coin worth 5 cents.'),
    ('21000000-0000-0000-0000-000000000017', 'G2-MONEY-01', 'MONEY', 2, 'You have 2 dimes and 1 nickel. How many cents do you have?', 2, '2 dimes (20 cents) plus 1 nickel (5 cents) is 25 cents.', 'Each dime is 10 cents; add the nickel''s 5 cents.'),
    ('21000000-0000-0000-0000-000000000018', 'G2-MONEY-01', 'MONEY', 3, 'A quarter is worth how many cents?', 2, 'A quarter is worth 25 cents.', 'A quarter is the coin worth 25 cents.'),

    ('21000000-0000-0000-0000-000000000019', 'G2-MEASURE-01', 'MEASURE_LEN', 1, 'Which tool do we use to measure how long something is?', 0, 'A ruler measures length.', 'Think about what tool has inch and centimeter marks.'),
    ('21000000-0000-0000-0000-000000000020', 'G2-MEASURE-01', 'MEASURE_LEN', 2, 'A pencil is about how long?', 0, 'A typical pencil is about 7 inches long.', 'Think about the size of a pencil compared to a ruler.'),
    ('21000000-0000-0000-0000-000000000021', 'G2-MEASURE-01', 'MEASURE_LEN', 3, 'If a book is 10 inches long and a pencil is 7 inches long, how much longer is the book?', 1, '10 - 7 = 3 inches longer.', 'Subtract the pencil''s length from the book''s length.'),

    ('21000000-0000-0000-0000-000000000022', 'G2-SHAPE-01', 'SHAPES_G2', 1, 'How many sides does a hexagon have?', 1, 'A hexagon has 6 sides.', 'Think of a hexagon like a stop-sign shape, but with one less side.'),
    ('21000000-0000-0000-0000-000000000023', 'G2-SHAPE-01', 'SHAPES_G2', 2, 'Which shape is a 3D shape that looks like a ball?', 1, 'A sphere is a 3D shape shaped like a ball.', 'A circle is flat; its 3D version rolls.'),
    ('21000000-0000-0000-0000-000000000024', 'G2-SHAPE-01', 'SHAPES_G2', 3, 'How many corners does a cube have?', 1, 'A cube has 8 corners.', 'Picture a dice: count each pointed corner.'),

    ('21000000-0000-0000-0000-000000000025', 'G2-WORD-01', 'WORD_PROB_G2', 1, 'Jake had 20 apples. He gave away 8 and then picked 5 more. How many does he have now?', 0, '20 - 8 = 12, then 12 + 5 = 17.', 'Do the subtraction first, then the addition.'),
    ('21000000-0000-0000-0000-000000000026', 'G2-WORD-01', 'WORD_PROB_G2', 2, 'There are 3 boxes with 10 crayons each. How many crayons in total?', 1, '3 boxes of 10 is 10 + 10 + 10 = 30.', 'Try adding 10 three times.'),
    ('21000000-0000-0000-0000-000000000027', 'G2-WORD-01', 'WORD_PROB_G2', 3, 'Lily read 12 pages on Monday and 15 pages on Tuesday. How many pages in total?', 0, '12 + 15 = 27 pages.', 'Add the two days together.'),

    ('21000000-0000-0000-0000-000000000028', 'G2-ENG-COMP-01', 'COMPREHENSION_G2', 1, 'Read: "Tom has a red ball. He plays with it in the park." What color is Tom''s ball?', 1, 'The passage says Tom''s ball is red.', 'Look for the color word in the sentence.'),
    ('21000000-0000-0000-0000-000000000029', 'G2-ENG-COMP-01', 'COMPREHENSION_G2', 2, 'Read: "The cat sat on the mat and slept all day." What did the cat do?', 1, 'The passage says the cat slept all day.', 'Find the action word in the sentence.'),
    ('21000000-0000-0000-0000-000000000030', 'G2-ENG-COMP-01', 'COMPREHENSION_G2', 3, 'Read: "Mia baked cookies for her friends." Who did Mia bake cookies for?', 1, 'The passage says Mia baked cookies for her friends.', 'Look for who the cookies were for.'),

    ('21000000-0000-0000-0000-000000000031', 'G2-ENG-COMPOUND-01', 'COMPOUND_WORDS', 1, 'Which two words make the compound word "sunflower"?', 0, '"Sunflower" is made of "sun" and "flower."', 'Break the word into two smaller words you know.'),
    ('21000000-0000-0000-0000-000000000032', 'G2-ENG-COMPOUND-01', 'COMPOUND_WORDS', 2, 'What compound word means a box for mail?', 0, '"Mailbox" is made of "mail" and "box."', 'Think of "mail" plus a word for a container.'),
    ('21000000-0000-0000-0000-000000000033', 'G2-ENG-COMPOUND-01', 'COMPOUND_WORDS', 3, 'Which of these is a compound word?', 1, '"Butterfly" is made of "butter" and "fly."', 'Look for the word made of two smaller words.'),

    ('21000000-0000-0000-0000-000000000034', 'G2-ENG-CONTRACT-01', 'CONTRACTIONS', 1, 'What is the contraction for "do not"?', 0, '"Do not" becomes "don''t."', 'The apostrophe replaces the missing letter "o".'),
    ('21000000-0000-0000-0000-000000000035', 'G2-ENG-CONTRACT-01', 'CONTRACTIONS', 2, 'What does "it''s" stand for?', 1, '"It''s" is short for "it is."', 'Read the two words it''s standing in for.'),
    ('21000000-0000-0000-0000-000000000036', 'G2-ENG-CONTRACT-01', 'CONTRACTIONS', 3, 'What is the contraction for "I am"?', 0, '"I am" becomes "I''m."', 'The apostrophe replaces the missing letters "a".'),

    ('21000000-0000-0000-0000-000000000037', 'G2-ENG-SYNANT-01', 'SYNONYMS_ANTONYMS', 1, 'Which word means the same as "happy"?', 1, '"Glad" means the same as "happy" — they are synonyms.', 'Think of another word for feeling good.'),
    ('21000000-0000-0000-0000-000000000038', 'G2-ENG-SYNANT-01', 'SYNONYMS_ANTONYMS', 2, 'Which word is the opposite of "big"?', 2, '"Small" is the opposite of "big" — they are antonyms.', 'Think of the word that means the least amount of "big".'),
    ('21000000-0000-0000-0000-000000000039', 'G2-ENG-SYNANT-01', 'SYNONYMS_ANTONYMS', 3, 'Which word means the same as "fast"?', 0, '"Quick" means the same as "fast".', 'Think of another word for moving at high speed.'),

    ('21000000-0000-0000-0000-000000000040', 'G2-ENG-POS-01', 'PARTS_OF_SPEECH_G2', 1, 'In the sentence "The dog runs fast," which word is the verb?', 1, '"Runs" is the action word, so it is the verb.', 'A verb is the action word in a sentence.'),
    ('21000000-0000-0000-0000-000000000041', 'G2-ENG-POS-01', 'PARTS_OF_SPEECH_G2', 2, 'Which word is an adjective in "The tall tree swayed"?', 0, '"Tall" describes the tree, so it is the adjective.', 'An adjective describes a noun.'),
    ('21000000-0000-0000-0000-000000000042', 'G2-ENG-POS-01', 'PARTS_OF_SPEECH_G2', 3, 'Which word is a noun in "The bird flew away"?', 2, '"Bird" names a thing, so it is the noun.', 'A noun names a person, place, or thing.'),

    ('21000000-0000-0000-0000-000000000043', 'G2-ENG-PLURAL-01', 'PLURALS', 1, 'What is the plural of "cat"?', 0, 'Add "s" to make "cats."', 'Most words just add "s" to become plural.'),
    ('21000000-0000-0000-0000-000000000044', 'G2-ENG-PLURAL-01', 'PLURALS', 2, 'What is the plural of "box"?', 1, 'Words ending in "x" add "es": "boxes."', 'Words ending in x, s, ch, or sh add "es".'),
    ('21000000-0000-0000-0000-000000000045', 'G2-ENG-PLURAL-01', 'PLURALS', 3, 'What is the plural of "baby"?', 1, 'Change the "y" to "i" and add "es": "babies."', 'Words ending in a consonant plus "y" change the "y" to "ies".'),

    ('21000000-0000-0000-0000-000000000046', 'G2-ENG-SENTTYPE-01', 'SENTENCE_TYPES', 1, 'Which sentence is a question?', 1, '"Is the sun hot?" ends with a question mark, so it''s a question.', 'A question ends with a question mark.'),
    ('21000000-0000-0000-0000-000000000047', 'G2-ENG-SENTTYPE-01', 'SENTENCE_TYPES', 2, 'Which sentence shows excitement?', 0, '"I won the race!" ends with an exclamation point, showing excitement.', 'An exclamation point shows strong feeling.'),
    ('21000000-0000-0000-0000-000000000048', 'G2-ENG-SENTTYPE-01', 'SENTENCE_TYPES', 3, 'Which sentence is a statement?', 2, '"The door is closed." simply tells a fact, so it''s a statement.', 'A statement just tells something and ends with a period.'),

    ('21000000-0000-0000-0000-000000000049', 'G2-ENG-MAINIDEA-01', 'MAIN_IDEA', 1, 'Read: "Dogs need food, water, and exercise to stay healthy." What is this mostly about?', 1, 'The passage is mainly about what dogs need.', 'Ask yourself: what is every sentence talking about?'),
    ('21000000-0000-0000-0000-000000000050', 'G2-ENG-MAINIDEA-01', 'MAIN_IDEA', 2, 'Read: "Maria planted seeds, watered them, and watched them grow into flowers." What is the main idea?', 0, 'The passage is mainly about Maria growing flowers.', 'Look at what all the sentences have in common.'),
    ('21000000-0000-0000-0000-000000000051', 'G2-ENG-MAINIDEA-01', 'MAIN_IDEA', 3, 'Read: "The library has thousands of books on every subject." What is the passage mainly about?', 1, 'The passage is mainly about a library.', 'Look for the one topic every sentence connects to.');

INSERT INTO exercise_choices (exercise_id, choice_index, choice_text) VALUES
    ('21000000-0000-0000-0000-000000000001', 0, '38'), ('21000000-0000-0000-0000-000000000001', 1, '36'), ('21000000-0000-0000-0000-000000000001', 2, '40'),
    ('21000000-0000-0000-0000-000000000002', 0, '65'), ('21000000-0000-0000-0000-000000000002', 1, '75'), ('21000000-0000-0000-0000-000000000002', 2, '85'),
    ('21000000-0000-0000-0000-000000000003', 0, '72'), ('21000000-0000-0000-0000-000000000003', 1, '82'), ('21000000-0000-0000-0000-000000000003', 2, '92'),

    ('21000000-0000-0000-0000-000000000004', 0, '33'), ('21000000-0000-0000-0000-000000000004', 1, '43'), ('21000000-0000-0000-0000-000000000004', 2, '23'),
    ('21000000-0000-0000-0000-000000000005', 0, '45'), ('21000000-0000-0000-0000-000000000005', 1, '55'), ('21000000-0000-0000-0000-000000000005', 2, '35'),
    ('21000000-0000-0000-0000-000000000006', 0, '43'), ('21000000-0000-0000-0000-000000000006', 1, '53'), ('21000000-0000-0000-0000-000000000006', 2, '33'),

    ('21000000-0000-0000-0000-000000000007', 0, '4'), ('21000000-0000-0000-0000-000000000007', 1, '7'), ('21000000-0000-0000-0000-000000000007', 2, '47'),
    ('21000000-0000-0000-0000-000000000008', 0, '36'), ('21000000-0000-0000-0000-000000000008', 1, '63'), ('21000000-0000-0000-0000-000000000008', 2, '69'),
    ('21000000-0000-0000-0000-000000000009', 0, '8'), ('21000000-0000-0000-0000-000000000009', 1, '2'), ('21000000-0000-0000-0000-000000000009', 2, '82'),

    ('21000000-0000-0000-0000-000000000010', 0, '7'), ('21000000-0000-0000-0000-000000000010', 1, '8'), ('21000000-0000-0000-0000-000000000010', 2, '9'),
    ('21000000-0000-0000-0000-000000000011', 0, '20'), ('21000000-0000-0000-0000-000000000011', 1, '18'), ('21000000-0000-0000-0000-000000000011', 2, '25'),
    ('21000000-0000-0000-0000-000000000012', 0, '35'), ('21000000-0000-0000-0000-000000000012', 1, '40'), ('21000000-0000-0000-0000-000000000012', 2, '50'),

    ('21000000-0000-0000-0000-000000000013', 0, '3:00'), ('21000000-0000-0000-0000-000000000013', 1, '12:00'), ('21000000-0000-0000-0000-000000000013', 2, '3:30'),
    ('21000000-0000-0000-0000-000000000014', 0, '7:30'), ('21000000-0000-0000-0000-000000000014', 1, '8:00'), ('21000000-0000-0000-0000-000000000014', 2, '6:30'),
    ('21000000-0000-0000-0000-000000000015', 0, '4:30'), ('21000000-0000-0000-0000-000000000015', 1, '5:00'), ('21000000-0000-0000-0000-000000000015', 2, '4:15'),

    ('21000000-0000-0000-0000-000000000016', 0, '1 cent'), ('21000000-0000-0000-0000-000000000016', 1, '5 cents'), ('21000000-0000-0000-0000-000000000016', 2, '10 cents'),
    ('21000000-0000-0000-0000-000000000017', 0, '15 cents'), ('21000000-0000-0000-0000-000000000017', 1, '20 cents'), ('21000000-0000-0000-0000-000000000017', 2, '25 cents'),
    ('21000000-0000-0000-0000-000000000018', 0, '10 cents'), ('21000000-0000-0000-0000-000000000018', 1, '20 cents'), ('21000000-0000-0000-0000-000000000018', 2, '25 cents'),

    ('21000000-0000-0000-0000-000000000019', 0, 'Ruler'), ('21000000-0000-0000-0000-000000000019', 1, 'Clock'), ('21000000-0000-0000-0000-000000000019', 2, 'Scale'),
    ('21000000-0000-0000-0000-000000000020', 0, '7 inches'), ('21000000-0000-0000-0000-000000000020', 1, '7 feet'), ('21000000-0000-0000-0000-000000000020', 2, '7 miles'),
    ('21000000-0000-0000-0000-000000000021', 0, '2 inches'), ('21000000-0000-0000-0000-000000000021', 1, '3 inches'), ('21000000-0000-0000-0000-000000000021', 2, '4 inches'),

    ('21000000-0000-0000-0000-000000000022', 0, '5'), ('21000000-0000-0000-0000-000000000022', 1, '6'), ('21000000-0000-0000-0000-000000000022', 2, '7'),
    ('21000000-0000-0000-0000-000000000023', 0, 'Circle'), ('21000000-0000-0000-0000-000000000023', 1, 'Sphere'), ('21000000-0000-0000-0000-000000000023', 2, 'Square'),
    ('21000000-0000-0000-0000-000000000024', 0, '6'), ('21000000-0000-0000-0000-000000000024', 1, '8'), ('21000000-0000-0000-0000-000000000024', 2, '12'),

    ('21000000-0000-0000-0000-000000000025', 0, '17'), ('21000000-0000-0000-0000-000000000025', 1, '13'), ('21000000-0000-0000-0000-000000000025', 2, '25'),
    ('21000000-0000-0000-0000-000000000026', 0, '13'), ('21000000-0000-0000-0000-000000000026', 1, '30'), ('21000000-0000-0000-0000-000000000026', 2, '33'),
    ('21000000-0000-0000-0000-000000000027', 0, '27'), ('21000000-0000-0000-0000-000000000027', 1, '37'), ('21000000-0000-0000-0000-000000000027', 2, '3'),

    ('21000000-0000-0000-0000-000000000028', 0, 'Blue'), ('21000000-0000-0000-0000-000000000028', 1, 'Red'), ('21000000-0000-0000-0000-000000000028', 2, 'Green'),
    ('21000000-0000-0000-0000-000000000029', 0, 'Ran'), ('21000000-0000-0000-0000-000000000029', 1, 'Slept'), ('21000000-0000-0000-0000-000000000029', 2, 'Jumped'),
    ('21000000-0000-0000-0000-000000000030', 0, 'Her family'), ('21000000-0000-0000-0000-000000000030', 1, 'Her friends'), ('21000000-0000-0000-0000-000000000030', 2, 'Her teacher'),

    ('21000000-0000-0000-0000-000000000031', 0, 'sun + flower'), ('21000000-0000-0000-0000-000000000031', 1, 'son + flower'), ('21000000-0000-0000-0000-000000000031', 2, 'sun + flow'),
    ('21000000-0000-0000-0000-000000000032', 0, 'mailbox'), ('21000000-0000-0000-0000-000000000032', 1, 'mailbag'), ('21000000-0000-0000-0000-000000000032', 2, 'mailman'),
    ('21000000-0000-0000-0000-000000000033', 0, 'happy'), ('21000000-0000-0000-0000-000000000033', 1, 'butterfly'), ('21000000-0000-0000-0000-000000000033', 2, 'running'),

    ('21000000-0000-0000-0000-000000000034', 0, 'don''t'), ('21000000-0000-0000-0000-000000000034', 1, 'dont''t'), ('21000000-0000-0000-0000-000000000034', 2, 'do''nt'),
    ('21000000-0000-0000-0000-000000000035', 0, 'its own'), ('21000000-0000-0000-0000-000000000035', 1, 'it is'), ('21000000-0000-0000-0000-000000000035', 2, 'it was'),
    ('21000000-0000-0000-0000-000000000036', 0, 'I''m'), ('21000000-0000-0000-0000-000000000036', 1, 'Im'''), ('21000000-0000-0000-0000-000000000036', 2, 'I''am'),

    ('21000000-0000-0000-0000-000000000037', 0, 'Sad'), ('21000000-0000-0000-0000-000000000037', 1, 'Glad'), ('21000000-0000-0000-0000-000000000037', 2, 'Mad'),
    ('21000000-0000-0000-0000-000000000038', 0, 'Large'), ('21000000-0000-0000-0000-000000000038', 1, 'Huge'), ('21000000-0000-0000-0000-000000000038', 2, 'Small'),
    ('21000000-0000-0000-0000-000000000039', 0, 'Quick'), ('21000000-0000-0000-0000-000000000039', 1, 'Slow'), ('21000000-0000-0000-0000-000000000039', 2, 'Loud'),

    ('21000000-0000-0000-0000-000000000040', 0, 'dog'), ('21000000-0000-0000-0000-000000000040', 1, 'runs'), ('21000000-0000-0000-0000-000000000040', 2, 'fast'),
    ('21000000-0000-0000-0000-000000000041', 0, 'tall'), ('21000000-0000-0000-0000-000000000041', 1, 'tree'), ('21000000-0000-0000-0000-000000000041', 2, 'swayed'),
    ('21000000-0000-0000-0000-000000000042', 0, 'flew'), ('21000000-0000-0000-0000-000000000042', 1, 'away'), ('21000000-0000-0000-0000-000000000042', 2, 'bird'),

    ('21000000-0000-0000-0000-000000000043', 0, 'cats'), ('21000000-0000-0000-0000-000000000043', 1, 'cates'), ('21000000-0000-0000-0000-000000000043', 2, 'cat''s'),
    ('21000000-0000-0000-0000-000000000044', 0, 'boxs'), ('21000000-0000-0000-0000-000000000044', 1, 'boxes'), ('21000000-0000-0000-0000-000000000044', 2, 'boxies'),
    ('21000000-0000-0000-0000-000000000045', 0, 'babys'), ('21000000-0000-0000-0000-000000000045', 1, 'babies'), ('21000000-0000-0000-0000-000000000045', 2, 'baby''s'),

    ('21000000-0000-0000-0000-000000000046', 0, 'The sun is hot.'), ('21000000-0000-0000-0000-000000000046', 1, 'Is the sun hot?'), ('21000000-0000-0000-0000-000000000046', 2, 'The sun, it is hot!'),
    ('21000000-0000-0000-0000-000000000047', 0, 'I won the race!'), ('21000000-0000-0000-0000-000000000047', 1, 'I won the race.'), ('21000000-0000-0000-0000-000000000047', 2, 'Did I win the race?'),
    ('21000000-0000-0000-0000-000000000048', 0, 'Close the door!'), ('21000000-0000-0000-0000-000000000048', 1, 'Is the door closed?'), ('21000000-0000-0000-0000-000000000048', 2, 'The door is closed.'),

    ('21000000-0000-0000-0000-000000000049', 0, 'Cats'), ('21000000-0000-0000-0000-000000000049', 1, 'What dogs need'), ('21000000-0000-0000-0000-000000000049', 2, 'The weather'),
    ('21000000-0000-0000-0000-000000000050', 0, 'Maria grew flowers'), ('21000000-0000-0000-0000-000000000050', 1, 'Maria likes water'), ('21000000-0000-0000-0000-000000000050', 2, 'Maria has a dog'),
    ('21000000-0000-0000-0000-000000000051', 0, 'A park'), ('21000000-0000-0000-0000-000000000051', 1, 'A library'), ('21000000-0000-0000-0000-000000000051', 2, 'A school');
