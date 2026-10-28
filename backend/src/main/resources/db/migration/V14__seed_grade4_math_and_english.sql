-- Grade 4 curriculum: 9 Math lessons + 8 English lessons.

INSERT INTO skills (code, subject_code, name) VALUES
    ('MULT_MULTIDIGIT', 'MATH', 'Multi-Digit Multiplication'),
    ('LONG_DIV', 'MATH', 'Long Division Introduction'),
    ('FRAC_EQUIV', 'MATH', 'Fraction Equivalence'),
    ('FRAC_COMPARE', 'MATH', 'Comparing Fractions'),
    ('DECIMALS_INTRO', 'MATH', 'Decimals Introduction'),
    ('FACTORS_MULTIPLES', 'MATH', 'Factors and Multiples'),
    ('ANGLES_G4', 'MATH', 'Angles and Geometry'),
    ('WORD_PROB_G4', 'MATH', 'Multi-Step Word Problems'),
    ('AREA_PERIMETER_G4', 'MATH', 'Area and Perimeter: Harder Shapes'),
    ('COMPREHENSION_G4', 'ENGLISH', 'Reading Comprehension'),
    ('FIGURATIVE_LANG', 'ENGLISH', 'Figurative Language'),
    ('MAIN_IDEA_DETAILS', 'ENGLISH', 'Main Idea and Details'),
    ('SUMMARIZING', 'ENGLISH', 'Summarizing'),
    ('VERB_TENSES', 'ENGLISH', 'Verb Tenses'),
    ('VOCAB_G4', 'ENGLISH', 'Vocabulary Building'),
    ('TEXT_STRUCTURE', 'ENGLISH', 'Text Structure'),
    ('AUTHORS_PURPOSE', 'ENGLISH', 'Author''s Purpose');

INSERT INTO lessons (id, code, subject_code, grade_level, display_order, title, description) VALUES
    ('15000000-0000-0000-0000-000000000001', 'G4-MULT-01', 'MATH', 'GRADE_4', 1, 'Multi-Digit Multiplication', 'Multiply a two-digit number by a one-digit number.'),
    ('15000000-0000-0000-0000-000000000002', 'G4-DIV-01', 'MATH', 'GRADE_4', 2, 'Long Division Introduction', 'Divide two-digit numbers evenly.'),
    ('15000000-0000-0000-0000-000000000003', 'G4-FRACEQ-01', 'MATH', 'GRADE_4', 3, 'Fraction Equivalence', 'Find fractions that name the same amount.'),
    ('15000000-0000-0000-0000-000000000004', 'G4-FRACCOMP-01', 'MATH', 'GRADE_4', 4, 'Comparing Fractions', 'Tell which of two fractions is larger.'),
    ('15000000-0000-0000-0000-000000000005', 'G4-DECIMAL-01', 'MATH', 'GRADE_4', 5, 'Decimals Introduction', 'Connect decimals to fractions and compare them.'),
    ('15000000-0000-0000-0000-000000000006', 'G4-FACTOR-01', 'MATH', 'GRADE_4', 6, 'Factors and Multiples', 'Find the factors and multiples of a number.'),
    ('15000000-0000-0000-0000-000000000007', 'G4-ANGLE-01', 'MATH', 'GRADE_4', 7, 'Angles and Geometry', 'Classify angles as acute, right, or obtuse.'),
    ('15000000-0000-0000-0000-000000000008', 'G4-WORD-01', 'MATH', 'GRADE_4', 8, 'Multi-Step Word Problems', 'Solve problems that take more than one step.'),
    ('15000000-0000-0000-0000-000000000009', 'G4-AREA-01', 'MATH', 'GRADE_4', 9, 'Area and Perimeter: Harder Shapes', 'Find the area and perimeter of bigger rectangles.'),
    ('15000000-0000-0000-0000-000000000010', 'G4-ENG-COMP-01', 'ENGLISH', 'GRADE_4', 1, 'Reading Comprehension', 'Infer what a character is like from their actions.'),
    ('15000000-0000-0000-0000-000000000011', 'G4-ENG-FIGLANG-01', 'ENGLISH', 'GRADE_4', 2, 'Figurative Language', 'Spot similes and metaphors in writing.'),
    ('15000000-0000-0000-0000-000000000012', 'G4-ENG-MAINIDEA-01', 'ENGLISH', 'GRADE_4', 3, 'Main Idea and Details', 'Tell the main idea apart from supporting details.'),
    ('15000000-0000-0000-0000-000000000013', 'G4-ENG-SUMMARY-01', 'ENGLISH', 'GRADE_4', 4, 'Summarizing', 'Shrink a passage down to its most important points.'),
    ('15000000-0000-0000-0000-000000000014', 'G4-ENG-TENSE-01', 'ENGLISH', 'GRADE_4', 5, 'Verb Tenses', 'Tell past, present, and future tense apart.'),
    ('15000000-0000-0000-0000-000000000015', 'G4-ENG-VOCAB-01', 'ENGLISH', 'GRADE_4', 6, 'Vocabulary Building', 'Learn the meaning of grade-level words.'),
    ('15000000-0000-0000-0000-000000000016', 'G4-ENG-STRUCT-01', 'ENGLISH', 'GRADE_4', 7, 'Text Structure', 'Recognize how a passage is organized.'),
    ('15000000-0000-0000-0000-000000000017', 'G4-ENG-PURPOSE-01', 'ENGLISH', 'GRADE_4', 8, 'Author''s Purpose', 'Figure out why a piece of writing was written.');

INSERT INTO exercises (id, lesson_code, skill_code, display_order, prompt, answer_index, explanation, hint) VALUES
    ('25000000-0000-0000-0000-000000000001', 'G4-MULT-01', 'MULT_MULTIDIGIT', 1, 'What is 23 x 4?', 1, '23 x 4 = 92.', 'Multiply the ones (3x4=12), then the tens (20x4=80), and add: 80+12=92.'),
    ('25000000-0000-0000-0000-000000000002', 'G4-MULT-01', 'MULT_MULTIDIGIT', 2, 'What is 15 x 6?', 1, '15 x 6 = 90.', 'Multiply the ones (5x6=30), then the tens (10x6=60), and add: 60+30=90.'),
    ('25000000-0000-0000-0000-000000000003', 'G4-MULT-01', 'MULT_MULTIDIGIT', 3, 'What is 34 x 3?', 1, '34 x 3 = 102.', 'Multiply the ones (4x3=12), then the tens (30x3=90), and add: 90+12=102.'),

    ('25000000-0000-0000-0000-000000000004', 'G4-DIV-01', 'LONG_DIV', 1, 'What is 84 / 4?', 1, '84 / 4 = 21, since 4 x 21 = 84.', 'Try dividing 80 by 4 first, then the rest.'),
    ('25000000-0000-0000-0000-000000000005', 'G4-DIV-01', 'LONG_DIV', 2, 'What is 96 / 8?', 1, '96 / 8 = 12, since 8 x 12 = 96.', 'Try dividing 80 by 8 first, then the rest.'),
    ('25000000-0000-0000-0000-000000000006', 'G4-DIV-01', 'LONG_DIV', 3, 'What is 72 / 6?', 1, '72 / 6 = 12, since 6 x 12 = 72.', 'Try dividing 60 by 6 first, then the rest.'),

    ('25000000-0000-0000-0000-000000000007', 'G4-FRACEQ-01', 'FRAC_EQUIV', 1, 'Which fraction equals 1/2?', 0, '2/4 simplifies to 1/2.', 'Divide the top and bottom by the same number.'),
    ('25000000-0000-0000-0000-000000000008', 'G4-FRACEQ-01', 'FRAC_EQUIV', 2, 'Which fraction equals 2/3?', 1, '4/6 simplifies to 2/3.', 'Divide the top and bottom by the same number.'),
    ('25000000-0000-0000-0000-000000000009', 'G4-FRACEQ-01', 'FRAC_EQUIV', 3, 'Which fraction equals 1/4?', 0, '2/8 simplifies to 1/4.', 'Divide the top and bottom by the same number.'),

    ('25000000-0000-0000-0000-000000000010', 'G4-FRACCOMP-01', 'FRAC_COMPARE', 1, 'Which fraction is bigger: 1/2 or 1/4?', 0, '1/2 is bigger than 1/4 — half is more than a quarter.', 'A smaller bottom number (with the same top) means a bigger piece.'),
    ('25000000-0000-0000-0000-000000000011', 'G4-FRACCOMP-01', 'FRAC_COMPARE', 2, 'Which fraction is bigger: 2/3 or 1/3?', 0, '2/3 is bigger than 1/3 since 2 parts is more than 1 part.', 'Compare how many parts out of the same total you have.'),
    ('25000000-0000-0000-0000-000000000012', 'G4-FRACCOMP-01', 'FRAC_COMPARE', 3, 'Which fraction is smaller: 3/4 or 1/2?', 1, '1/2 is smaller than 3/4.', 'Picture both fractions as parts of the same whole.'),

    ('25000000-0000-0000-0000-000000000013', 'G4-DECIMAL-01', 'DECIMALS_INTRO', 1, 'What is 0.5 the same as?', 0, '0.5 is the same as the fraction 1/2.', 'Think about cutting a whole into 10 equal parts and taking 5.'),
    ('25000000-0000-0000-0000-000000000014', 'G4-DECIMAL-01', 'DECIMALS_INTRO', 2, 'Which is bigger: 0.7 or 0.3?', 0, '0.7 is bigger than 0.3.', 'Compare the digit right after the decimal point.'),
    ('25000000-0000-0000-0000-000000000015', 'G4-DECIMAL-01', 'DECIMALS_INTRO', 3, 'What is 1.5 + 2.0?', 1, '1.5 + 2.0 = 3.5.', 'Add the whole numbers, then the decimal parts.'),

    ('25000000-0000-0000-0000-000000000016', 'G4-FACTOR-01', 'FACTORS_MULTIPLES', 1, 'Which number is a factor of 12?', 1, '4 is a factor of 12, since 4 x 3 = 12.', 'A factor divides evenly into the number with no remainder.'),
    ('25000000-0000-0000-0000-000000000017', 'G4-FACTOR-01', 'FACTORS_MULTIPLES', 2, 'What is a multiple of 5?', 1, '15 is a multiple of 5, since 5 x 3 = 15.', 'A multiple is what you get when you count by that number.'),
    ('25000000-0000-0000-0000-000000000018', 'G4-FACTOR-01', 'FACTORS_MULTIPLES', 3, 'Which number is a factor of 20?', 1, '5 is a factor of 20, since 5 x 4 = 20.', 'A factor divides evenly into the number with no remainder.'),

    ('25000000-0000-0000-0000-000000000019', 'G4-ANGLE-01', 'ANGLES_G4', 1, 'What do we call an angle that looks like the corner of a square (90 degrees)?', 1, 'A 90-degree angle is called a right angle.', 'Think of the corner of a piece of paper.'),
    ('25000000-0000-0000-0000-000000000020', 'G4-ANGLE-01', 'ANGLES_G4', 2, 'What do we call an angle smaller than 90 degrees?', 0, 'An angle smaller than 90 degrees is called acute.', 'Think of a narrow, pointy angle.'),
    ('25000000-0000-0000-0000-000000000021', 'G4-ANGLE-01', 'ANGLES_G4', 3, 'What do we call an angle bigger than 90 degrees?', 2, 'An angle bigger than 90 degrees is called obtuse.', 'Think of a wide, open angle.'),

    ('25000000-0000-0000-0000-000000000022', 'G4-WORD-01', 'WORD_PROB_G4', 1, 'Tom buys 3 packs of pencils with 8 pencils each, then gives away 6. How many does he have left?', 1, '3 x 8 = 24, then 24 - 6 = 18.', 'First multiply to find the total, then subtract.'),
    ('25000000-0000-0000-0000-000000000023', 'G4-WORD-01', 'WORD_PROB_G4', 2, 'A box has 5 shelves with 12 books each. If 7 books are removed, how many are left?', 0, '5 x 12 = 60, then 60 - 7 = 53.', 'First multiply to find the total, then subtract.'),
    ('25000000-0000-0000-0000-000000000024', 'G4-WORD-01', 'WORD_PROB_G4', 3, 'Sara earns $4 an hour. If she works 6 hours and spends $10, how much does she have left?', 1, '4 x 6 = 24, then 24 - 10 = 14.', 'First multiply to find her earnings, then subtract what she spent.'),

    ('25000000-0000-0000-0000-000000000025', 'G4-AREA-01', 'AREA_PERIMETER_G4', 1, 'A rectangle is 8 units long and 5 units wide. What is its area?', 1, 'Area = 8 x 5 = 40.', 'Multiply the length by the width.'),
    ('25000000-0000-0000-0000-000000000026', 'G4-AREA-01', 'AREA_PERIMETER_G4', 2, 'A garden is 10 feet by 6 feet. What is its perimeter?', 1, 'Perimeter = 2 x (10+6) = 32.', 'Add all four sides: two lengths and two widths.'),
    ('25000000-0000-0000-0000-000000000027', 'G4-AREA-01', 'AREA_PERIMETER_G4', 3, 'A room is 7 meters by 4 meters. What is its area?', 2, 'Area = 7 x 4 = 28.', 'Multiply the length by the width.'),

    ('25000000-0000-0000-0000-000000000028', 'G4-ENG-COMP-01', 'COMPREHENSION_G4', 1, 'Read: "Though Ben was scared of heights, he climbed the ladder to save his cat from the roof." What does this show about Ben?', 1, 'Ben overcame his fear to help his cat, showing he was brave despite being scared.', 'Look at what Ben did even though he was afraid.'),
    ('25000000-0000-0000-0000-000000000029', 'G4-ENG-COMP-01', 'COMPREHENSION_G4', 2, 'Read: "The team had lost every game, but they kept practicing hard every day." What can you infer about the team?', 1, 'Continuing to practice hard despite losing shows determination.', 'Think about what continuing to practice says about their attitude.'),
    ('25000000-0000-0000-0000-000000000030', 'G4-ENG-COMP-01', 'COMPREHENSION_G4', 3, 'Read: "Despite the storm warning, the fishermen decided to stay docked." What did the fishermen decide?', 1, 'The passage says they decided to stay docked.', 'Look for the decision stated in the sentence.'),

    ('25000000-0000-0000-0000-000000000031', 'G4-ENG-FIGLANG-01', 'FIGURATIVE_LANG', 1, '"Her smile was as bright as the sun" is an example of what?', 0, 'This uses "as," comparing two things directly — that makes it a simile.', 'A simile uses "like" or "as" to compare two things.'),
    ('25000000-0000-0000-0000-000000000032', 'G4-ENG-FIGLANG-01', 'FIGURATIVE_LANG', 2, '"Time is a thief" is an example of what?', 1, 'This says one thing IS another without "like" or "as" — that makes it a metaphor.', 'A metaphor says one thing is another, without using "like" or "as".'),
    ('25000000-0000-0000-0000-000000000033', 'G4-ENG-FIGLANG-01', 'FIGURATIVE_LANG', 3, 'Which phrase is a simile?', 1, '"He fought like a lion" uses "like" to compare, making it a simile.', 'Look for the word "like" or "as" in the comparison.'),

    ('25000000-0000-0000-0000-000000000034', 'G4-ENG-MAINIDEA-01', 'MAIN_IDEA_DETAILS', 1, 'Read: "Bees collect nectar, make honey, and pollinate flowers." Which is a supporting detail, not the main idea?', 1, '"Bees make honey" is one supporting detail about what bees do.', 'A detail is one specific fact, not the whole topic.'),
    ('25000000-0000-0000-0000-000000000035', 'G4-ENG-MAINIDEA-01', 'MAIN_IDEA_DETAILS', 2, 'What is a "supporting detail"?', 1, 'A supporting detail is a fact that backs up the main idea.', 'Think about what "supporting" means — it helps hold up something else.'),
    ('25000000-0000-0000-0000-000000000036', 'G4-ENG-MAINIDEA-01', 'MAIN_IDEA_DETAILS', 3, 'Read: "Volcanoes form when magma rises to the Earth''s surface." What is the main idea?', 0, 'The passage is mainly about how volcanoes form.', 'Ask yourself what the whole sentence is explaining.'),

    ('25000000-0000-0000-0000-000000000037', 'G4-ENG-SUMMARY-01', 'SUMMARIZING', 1, 'A good summary should be:', 1, 'A summary should be shorter than the original and cover the main points.', 'Think about the purpose of a summary — to save time.'),
    ('25000000-0000-0000-0000-000000000038', 'G4-ENG-SUMMARY-01', 'SUMMARIZING', 2, 'When summarizing a story, you should include:', 1, 'A summary focuses on the most important events, not every detail.', 'Think about what matters most to the story.'),
    ('25000000-0000-0000-0000-000000000039', 'G4-ENG-SUMMARY-01', 'SUMMARIZING', 3, 'Which is the best summary of "A boy trained his puppy to sit, stay, and fetch over several weeks"?', 1, 'This summary captures the main action and the time it took.', 'A good summary keeps the key action and drops extra detail.'),

    ('25000000-0000-0000-0000-000000000040', 'G4-ENG-TENSE-01', 'VERB_TENSES', 1, 'Which sentence is in the past tense?', 1, '"She walked to school" uses the past tense verb "walked."', 'Past tense verbs often end in "-ed".'),
    ('25000000-0000-0000-0000-000000000041', 'G4-ENG-TENSE-01', 'VERB_TENSES', 2, 'Which sentence is in the future tense?', 2, '"He will play soccer" uses "will," which signals future tense.', 'Future tense often uses the word "will".'),
    ('25000000-0000-0000-0000-000000000042', 'G4-ENG-TENSE-01', 'VERB_TENSES', 3, 'Which sentence is in the present tense?', 0, '"They eat lunch" describes something happening now, so it is present tense.', 'Present tense describes what is happening right now.'),

    ('25000000-0000-0000-0000-000000000043', 'G4-ENG-VOCAB-01', 'VOCAB_G4', 1, 'What does "enormous" mean?', 1, '"Enormous" means very large.', 'Think of a word that describes something huge.'),
    ('25000000-0000-0000-0000-000000000044', 'G4-ENG-VOCAB-01', 'VOCAB_G4', 2, 'What does "exhausted" mean?', 1, '"Exhausted" means very tired.', 'Think about how you feel after a long, hard day.'),
    ('25000000-0000-0000-0000-000000000045', 'G4-ENG-VOCAB-01', 'VOCAB_G4', 3, 'What does "curious" mean?', 0, '"Curious" means wanting to know more about something.', 'Think about how you feel when you have lots of questions.'),

    ('25000000-0000-0000-0000-000000000046', 'G4-ENG-STRUCT-01', 'TEXT_STRUCTURE', 1, 'A passage that explains steps in order is using what structure?', 0, 'Explaining steps in order is a sequence structure.', 'Think about words like "first," "next," and "last".'),
    ('25000000-0000-0000-0000-000000000047', 'G4-ENG-STRUCT-01', 'TEXT_STRUCTURE', 2, 'A passage explaining why something happened is using what structure?', 1, 'Explaining why something happened is a cause and effect structure.', 'Think about words like "because" and "as a result".'),
    ('25000000-0000-0000-0000-000000000048', 'G4-ENG-STRUCT-01', 'TEXT_STRUCTURE', 3, 'A passage showing how two things are alike and different uses what structure?', 0, 'Showing similarities and differences is a compare and contrast structure.', 'Think about words like "similarly" and "on the other hand".'),

    ('25000000-0000-0000-0000-000000000049', 'G4-ENG-PURPOSE-01', 'AUTHORS_PURPOSE', 1, 'A story meant to make you laugh has what purpose?', 1, 'A story meant to make you laugh is written to entertain.', 'Think about why someone would write something funny.'),
    ('25000000-0000-0000-0000-000000000050', 'G4-ENG-PURPOSE-01', 'AUTHORS_PURPOSE', 2, 'A textbook chapter about volcanoes has what purpose?', 0, 'A textbook chapter is written to inform.', 'Think about why textbooks are written.'),
    ('25000000-0000-0000-0000-000000000051', 'G4-ENG-PURPOSE-01', 'AUTHORS_PURPOSE', 3, 'An ad trying to get you to buy a toy has what purpose?', 2, 'An ad is written to persuade you to do something, like buy a toy.', 'Think about what ads are trying to get you to do.');

INSERT INTO exercise_choices (exercise_id, choice_index, choice_text) VALUES
    ('25000000-0000-0000-0000-000000000001', 0, '82'), ('25000000-0000-0000-0000-000000000001', 1, '92'), ('25000000-0000-0000-0000-000000000001', 2, '102'),
    ('25000000-0000-0000-0000-000000000002', 0, '80'), ('25000000-0000-0000-0000-000000000002', 1, '90'), ('25000000-0000-0000-0000-000000000002', 2, '100'),
    ('25000000-0000-0000-0000-000000000003', 0, '92'), ('25000000-0000-0000-0000-000000000003', 1, '102'), ('25000000-0000-0000-0000-000000000003', 2, '112'),

    ('25000000-0000-0000-0000-000000000004', 0, '19'), ('25000000-0000-0000-0000-000000000004', 1, '21'), ('25000000-0000-0000-0000-000000000004', 2, '23'),
    ('25000000-0000-0000-0000-000000000005', 0, '10'), ('25000000-0000-0000-0000-000000000005', 1, '12'), ('25000000-0000-0000-0000-000000000005', 2, '14'),
    ('25000000-0000-0000-0000-000000000006', 0, '10'), ('25000000-0000-0000-0000-000000000006', 1, '12'), ('25000000-0000-0000-0000-000000000006', 2, '14'),

    ('25000000-0000-0000-0000-000000000007', 0, '2/4'), ('25000000-0000-0000-0000-000000000007', 1, '1/3'), ('25000000-0000-0000-0000-000000000007', 2, '3/5'),
    ('25000000-0000-0000-0000-000000000008', 0, '3/4'), ('25000000-0000-0000-0000-000000000008', 1, '4/6'), ('25000000-0000-0000-0000-000000000008', 2, '1/2'),
    ('25000000-0000-0000-0000-000000000009', 0, '2/8'), ('25000000-0000-0000-0000-000000000009', 1, '2/5'), ('25000000-0000-0000-0000-000000000009', 2, '3/8'),

    ('25000000-0000-0000-0000-000000000010', 0, '1/2'), ('25000000-0000-0000-0000-000000000010', 1, '1/4'), ('25000000-0000-0000-0000-000000000010', 2, 'Equal'),
    ('25000000-0000-0000-0000-000000000011', 0, '2/3'), ('25000000-0000-0000-0000-000000000011', 1, '1/3'), ('25000000-0000-0000-0000-000000000011', 2, 'Equal'),
    ('25000000-0000-0000-0000-000000000012', 0, '3/4'), ('25000000-0000-0000-0000-000000000012', 1, '1/2'), ('25000000-0000-0000-0000-000000000012', 2, 'Equal'),

    ('25000000-0000-0000-0000-000000000013', 0, '1/2'), ('25000000-0000-0000-0000-000000000013', 1, '1/4'), ('25000000-0000-0000-0000-000000000013', 2, '1/5'),
    ('25000000-0000-0000-0000-000000000014', 0, '0.7'), ('25000000-0000-0000-0000-000000000014', 1, '0.3'), ('25000000-0000-0000-0000-000000000014', 2, 'Equal'),
    ('25000000-0000-0000-0000-000000000015', 0, '3.0'), ('25000000-0000-0000-0000-000000000015', 1, '3.5'), ('25000000-0000-0000-0000-000000000015', 2, '4.0'),

    ('25000000-0000-0000-0000-000000000016', 0, '5'), ('25000000-0000-0000-0000-000000000016', 1, '4'), ('25000000-0000-0000-0000-000000000016', 2, '7'),
    ('25000000-0000-0000-0000-000000000017', 0, '12'), ('25000000-0000-0000-0000-000000000017', 1, '15'), ('25000000-0000-0000-0000-000000000017', 2, '22'),
    ('25000000-0000-0000-0000-000000000018', 0, '6'), ('25000000-0000-0000-0000-000000000018', 1, '5'), ('25000000-0000-0000-0000-000000000018', 2, '9'),

    ('25000000-0000-0000-0000-000000000019', 0, 'Acute'), ('25000000-0000-0000-0000-000000000019', 1, 'Right'), ('25000000-0000-0000-0000-000000000019', 2, 'Obtuse'),
    ('25000000-0000-0000-0000-000000000020', 0, 'Acute'), ('25000000-0000-0000-0000-000000000020', 1, 'Right'), ('25000000-0000-0000-0000-000000000020', 2, 'Obtuse'),
    ('25000000-0000-0000-0000-000000000021', 0, 'Acute'), ('25000000-0000-0000-0000-000000000021', 1, 'Right'), ('25000000-0000-0000-0000-000000000021', 2, 'Obtuse'),

    ('25000000-0000-0000-0000-000000000022', 0, '16'), ('25000000-0000-0000-0000-000000000022', 1, '18'), ('25000000-0000-0000-0000-000000000022', 2, '24'),
    ('25000000-0000-0000-0000-000000000023', 0, '53'), ('25000000-0000-0000-0000-000000000023', 1, '60'), ('25000000-0000-0000-0000-000000000023', 2, '67'),
    ('25000000-0000-0000-0000-000000000024', 0, '10'), ('25000000-0000-0000-0000-000000000024', 1, '14'), ('25000000-0000-0000-0000-000000000024', 2, '24'),

    ('25000000-0000-0000-0000-000000000025', 0, '13'), ('25000000-0000-0000-0000-000000000025', 1, '40'), ('25000000-0000-0000-0000-000000000025', 2, '45'),
    ('25000000-0000-0000-0000-000000000026', 0, '16'), ('25000000-0000-0000-0000-000000000026', 1, '32'), ('25000000-0000-0000-0000-000000000026', 2, '60'),
    ('25000000-0000-0000-0000-000000000027', 0, '11'), ('25000000-0000-0000-0000-000000000027', 1, '22'), ('25000000-0000-0000-0000-000000000027', 2, '28'),

    ('25000000-0000-0000-0000-000000000028', 0, 'He loves heights'), ('25000000-0000-0000-0000-000000000028', 1, 'He was brave despite his fear'), ('25000000-0000-0000-0000-000000000028', 2, 'He doesn''t like cats'),
    ('25000000-0000-0000-0000-000000000029', 0, 'They gave up'), ('25000000-0000-0000-0000-000000000029', 1, 'They were determined'), ('25000000-0000-0000-0000-000000000029', 2, 'They didn''t care'),
    ('25000000-0000-0000-0000-000000000030', 0, 'To sail anyway'), ('25000000-0000-0000-0000-000000000030', 1, 'To stay docked'), ('25000000-0000-0000-0000-000000000030', 2, 'To call for help'),

    ('25000000-0000-0000-0000-000000000031', 0, 'A simile'), ('25000000-0000-0000-0000-000000000031', 1, 'A metaphor'), ('25000000-0000-0000-0000-000000000031', 2, 'A fact'),
    ('25000000-0000-0000-0000-000000000032', 0, 'A simile'), ('25000000-0000-0000-0000-000000000032', 1, 'A metaphor'), ('25000000-0000-0000-0000-000000000032', 2, 'A fact'),
    ('25000000-0000-0000-0000-000000000033', 0, 'He is a lion in battle'), ('25000000-0000-0000-0000-000000000033', 1, 'He fought like a lion'), ('25000000-0000-0000-0000-000000000033', 2, 'He roared'),

    ('25000000-0000-0000-0000-000000000034', 0, 'Bees are insects'), ('25000000-0000-0000-0000-000000000034', 1, 'Bees make honey'), ('25000000-0000-0000-0000-000000000034', 2, 'Bees are important'),
    ('25000000-0000-0000-0000-000000000035', 0, 'The whole point of a passage'), ('25000000-0000-0000-0000-000000000035', 1, 'A fact that supports the main idea'), ('25000000-0000-0000-0000-000000000035', 2, 'An opinion'),
    ('25000000-0000-0000-0000-000000000036', 0, 'How volcanoes form'), ('25000000-0000-0000-0000-000000000036', 1, 'What magma tastes like'), ('25000000-0000-0000-0000-000000000036', 2, 'Where Earth is located'),

    ('25000000-0000-0000-0000-000000000037', 0, 'Longer than the original'), ('25000000-0000-0000-0000-000000000037', 1, 'Shorter and cover the main points'), ('25000000-0000-0000-0000-000000000037', 2, 'Exactly the same length'),
    ('25000000-0000-0000-0000-000000000038', 0, 'Every single detail'), ('25000000-0000-0000-0000-000000000038', 1, 'Only the most important events'), ('25000000-0000-0000-0000-000000000038', 2, 'Your own opinion'),
    ('25000000-0000-0000-0000-000000000039', 0, 'A boy had a puppy'), ('25000000-0000-0000-0000-000000000039', 1, 'A boy trained his puppy over time'), ('25000000-0000-0000-0000-000000000039', 2, 'A boy liked dogs'),

    ('25000000-0000-0000-0000-000000000040', 0, 'She walks to school.'), ('25000000-0000-0000-0000-000000000040', 1, 'She walked to school.'), ('25000000-0000-0000-0000-000000000040', 2, 'She will walk to school.'),
    ('25000000-0000-0000-0000-000000000041', 0, 'He plays soccer.'), ('25000000-0000-0000-0000-000000000041', 1, 'He played soccer.'), ('25000000-0000-0000-0000-000000000041', 2, 'He will play soccer.'),
    ('25000000-0000-0000-0000-000000000042', 0, 'They eat lunch.'), ('25000000-0000-0000-0000-000000000042', 1, 'They ate lunch.'), ('25000000-0000-0000-0000-000000000042', 2, 'They will eat lunch.'),

    ('25000000-0000-0000-0000-000000000043', 0, 'Very small'), ('25000000-0000-0000-0000-000000000043', 1, 'Very large'), ('25000000-0000-0000-0000-000000000043', 2, 'Very fast'),
    ('25000000-0000-0000-0000-000000000044', 0, 'Very excited'), ('25000000-0000-0000-0000-000000000044', 1, 'Very tired'), ('25000000-0000-0000-0000-000000000044', 2, 'Very hungry'),
    ('25000000-0000-0000-0000-000000000045', 0, 'Wanting to know more'), ('25000000-0000-0000-0000-000000000045', 1, 'Feeling scared'), ('25000000-0000-0000-0000-000000000045', 2, 'Feeling sleepy'),

    ('25000000-0000-0000-0000-000000000046', 0, 'Sequence'), ('25000000-0000-0000-0000-000000000046', 1, 'Compare and contrast'), ('25000000-0000-0000-0000-000000000046', 2, 'Cause and effect'),
    ('25000000-0000-0000-0000-000000000047', 0, 'Sequence'), ('25000000-0000-0000-0000-000000000047', 1, 'Cause and effect'), ('25000000-0000-0000-0000-000000000047', 2, 'Description'),
    ('25000000-0000-0000-0000-000000000048', 0, 'Compare and contrast'), ('25000000-0000-0000-0000-000000000048', 1, 'Sequence'), ('25000000-0000-0000-0000-000000000048', 2, 'Cause and effect'),

    ('25000000-0000-0000-0000-000000000049', 0, 'To inform'), ('25000000-0000-0000-0000-000000000049', 1, 'To entertain'), ('25000000-0000-0000-0000-000000000049', 2, 'To persuade'),
    ('25000000-0000-0000-0000-000000000050', 0, 'To inform'), ('25000000-0000-0000-0000-000000000050', 1, 'To entertain'), ('25000000-0000-0000-0000-000000000050', 2, 'To persuade'),
    ('25000000-0000-0000-0000-000000000051', 0, 'To inform'), ('25000000-0000-0000-0000-000000000051', 1, 'To entertain'), ('25000000-0000-0000-0000-000000000051', 2, 'To persuade');
