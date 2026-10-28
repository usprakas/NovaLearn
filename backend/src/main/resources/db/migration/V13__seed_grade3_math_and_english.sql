-- Grade 3 curriculum: 9 Math lessons + 8 English lessons.

INSERT INTO skills (code, subject_code, name) VALUES
    ('MULT_BASIC', 'MATH', 'Multiplication Basics'),
    ('DIV_BASIC', 'MATH', 'Division Basics'),
    ('FRACTIONS_INTRO', 'MATH', 'Fractions: Halves, Thirds, and Fourths'),
    ('AREA_PERIMETER', 'MATH', 'Area and Perimeter'),
    ('ROUNDING', 'MATH', 'Rounding Numbers'),
    ('TIME_MINUTE', 'MATH', 'Telling Time to the Minute'),
    ('BAR_GRAPHS', 'MATH', 'Reading Bar Graphs'),
    ('MULTIDIGIT_ADDSUB', 'MATH', 'Multi-Digit Addition and Subtraction'),
    ('WORD_PROB_G3', 'MATH', 'Multiplication and Division Word Problems'),
    ('COMPREHENSION_G3', 'ENGLISH', 'Reading Comprehension'),
    ('CONTEXT_CLUES', 'ENGLISH', 'Context Clues'),
    ('PREFIX_SUFFIX', 'ENGLISH', 'Prefixes and Suffixes'),
    ('PARTS_OF_SPEECH_G3', 'ENGLISH', 'Parts of Speech: Adverbs'),
    ('COMPARE_CONTRAST', 'ENGLISH', 'Compare and Contrast'),
    ('CAUSE_EFFECT', 'ENGLISH', 'Cause and Effect'),
    ('FACT_OPINION', 'ENGLISH', 'Fact vs. Opinion'),
    ('SUBJECT_VERB', 'ENGLISH', 'Subject-Verb Agreement');

INSERT INTO lessons (id, code, subject_code, grade_level, display_order, title, description) VALUES
    ('14000000-0000-0000-0000-000000000001', 'G3-MULT-01', 'MATH', 'GRADE_3', 1, 'Multiplication Basics', 'Multiply small numbers together.'),
    ('14000000-0000-0000-0000-000000000002', 'G3-DIV-01', 'MATH', 'GRADE_3', 2, 'Division Basics', 'Split numbers into equal groups.'),
    ('14000000-0000-0000-0000-000000000003', 'G3-FRAC-01', 'MATH', 'GRADE_3', 3, 'Fractions: Halves, Thirds, and Fourths', 'Understand simple fractions of a whole.'),
    ('14000000-0000-0000-0000-000000000004', 'G3-AREA-01', 'MATH', 'GRADE_3', 4, 'Area and Perimeter', 'Find the area and perimeter of a rectangle.'),
    ('14000000-0000-0000-0000-000000000005', 'G3-ROUND-01', 'MATH', 'GRADE_3', 5, 'Rounding Numbers', 'Round numbers to the nearest ten.'),
    ('14000000-0000-0000-0000-000000000006', 'G3-TIME-01', 'MATH', 'GRADE_3', 6, 'Telling Time to the Minute', 'Read a clock''s minute hand precisely.'),
    ('14000000-0000-0000-0000-000000000007', 'G3-GRAPH-01', 'MATH', 'GRADE_3', 7, 'Reading Bar Graphs', 'Compare values shown on a bar graph.'),
    ('14000000-0000-0000-0000-000000000008', 'G3-MULTIDIGIT-01', 'MATH', 'GRADE_3', 8, 'Multi-Digit Addition and Subtraction', 'Add and subtract numbers with three digits.'),
    ('14000000-0000-0000-0000-000000000009', 'G3-WORD-01', 'MATH', 'GRADE_3', 9, 'Multiplication and Division Word Problems', 'Solve real-world problems using multiplication and division.'),
    ('14000000-0000-0000-0000-000000000010', 'G3-ENG-COMP-01', 'ENGLISH', 'GRADE_3', 1, 'Reading Comprehension', 'Read a passage and figure out what will happen or why.'),
    ('14000000-0000-0000-0000-000000000011', 'G3-ENG-CONTEXT-01', 'ENGLISH', 'GRADE_3', 2, 'Context Clues', 'Figure out a word''s meaning from the sentence around it.'),
    ('14000000-0000-0000-0000-000000000012', 'G3-ENG-PREFIX-01', 'ENGLISH', 'GRADE_3', 3, 'Prefixes and Suffixes', 'Understand word parts added to the front or end of a word.'),
    ('14000000-0000-0000-0000-000000000013', 'G3-ENG-POS-01', 'ENGLISH', 'GRADE_3', 4, 'Parts of Speech: Adverbs', 'Find the word that describes how an action happens.'),
    ('14000000-0000-0000-0000-000000000014', 'G3-ENG-COMPARE-01', 'ENGLISH', 'GRADE_3', 5, 'Compare and Contrast', 'Find similarities and differences between two things.'),
    ('14000000-0000-0000-0000-000000000015', 'G3-ENG-CAUSE-01', 'ENGLISH', 'GRADE_3', 6, 'Cause and Effect', 'Tell what made something happen.'),
    ('14000000-0000-0000-0000-000000000016', 'G3-ENG-FACTOP-01', 'ENGLISH', 'GRADE_3', 7, 'Fact vs. Opinion', 'Tell the difference between a fact and an opinion.'),
    ('14000000-0000-0000-0000-000000000017', 'G3-ENG-SVA-01', 'ENGLISH', 'GRADE_3', 8, 'Subject-Verb Agreement', 'Match the verb to match its subject correctly.');

INSERT INTO exercises (id, lesson_code, skill_code, display_order, prompt, answer_index, explanation, hint) VALUES
    ('24000000-0000-0000-0000-000000000001', 'G3-MULT-01', 'MULT_BASIC', 1, 'What is 3 x 4?', 1, '3 x 4 = 12.', 'Add 3 four times: 3+3+3+3.'),
    ('24000000-0000-0000-0000-000000000002', 'G3-MULT-01', 'MULT_BASIC', 2, 'What is 5 x 2?', 1, '5 x 2 = 10.', 'Add 5 two times: 5+5.'),
    ('24000000-0000-0000-0000-000000000003', 'G3-MULT-01', 'MULT_BASIC', 3, 'What is 6 x 3?', 1, '6 x 3 = 18.', 'Add 6 three times: 6+6+6.'),

    ('24000000-0000-0000-0000-000000000004', 'G3-DIV-01', 'DIV_BASIC', 1, 'What is 12 / 3?', 1, '12 / 3 = 4, since 3 x 4 = 12.', 'Think about what number times 3 gives 12.'),
    ('24000000-0000-0000-0000-000000000005', 'G3-DIV-01', 'DIV_BASIC', 2, 'What is 20 / 4?', 1, '20 / 4 = 5, since 4 x 5 = 20.', 'Think about what number times 4 gives 20.'),
    ('24000000-0000-0000-0000-000000000006', 'G3-DIV-01', 'DIV_BASIC', 3, 'What is 18 / 6?', 1, '18 / 6 = 3, since 6 x 3 = 18.', 'Think about what number times 6 gives 18.'),

    ('24000000-0000-0000-0000-000000000007', 'G3-FRAC-01', 'FRACTIONS_INTRO', 1, 'If a pizza is cut into 4 equal slices and you eat 1, what fraction did you eat?', 1, 'Eating 1 of 4 equal slices is 1/4.', 'Count the total slices, then how many you ate.'),
    ('24000000-0000-0000-0000-000000000008', 'G3-FRAC-01', 'FRACTIONS_INTRO', 2, 'What fraction is shaded if half of a shape is colored in?', 0, 'Half of a shape is 1/2.', '"Half" always means 1 out of 2 equal parts.'),
    ('24000000-0000-0000-0000-000000000009', 'G3-FRAC-01', 'FRACTIONS_INTRO', 3, 'If a cake is cut into 3 equal pieces, what is each piece called?', 1, 'Each of 3 equal pieces is called a third.', 'Think about the word for "one out of three".'),

    ('24000000-0000-0000-0000-000000000010', 'G3-AREA-01', 'AREA_PERIMETER', 1, 'A rectangle is 4 units long and 3 units wide. What is its area?', 1, 'Area = length x width = 4 x 3 = 12.', 'Multiply the length by the width.'),
    ('24000000-0000-0000-0000-000000000011', 'G3-AREA-01', 'AREA_PERIMETER', 2, 'A square has sides of 5 units. What is its perimeter?', 1, 'Perimeter = 4 x side = 4 x 5 = 20.', 'A square has 4 equal sides — add them all up.'),
    ('24000000-0000-0000-0000-000000000012', 'G3-AREA-01', 'AREA_PERIMETER', 3, 'A rectangle is 6 units long and 2 units wide. What is its perimeter?', 2, 'Perimeter = 2 x (length + width) = 2 x (6+2) = 16.', 'Add all four sides: two lengths and two widths.'),

    ('24000000-0000-0000-0000-000000000013', 'G3-ROUND-01', 'ROUNDING', 1, 'Round 47 to the nearest ten.', 1, '47 is closer to 50 than to 40, so it rounds to 50.', 'Look at the ones digit: 7 rounds up.'),
    ('24000000-0000-0000-0000-000000000014', 'G3-ROUND-01', 'ROUNDING', 2, 'Round 23 to the nearest ten.', 0, '23 is closer to 20 than to 30, so it rounds to 20.', 'Look at the ones digit: 3 rounds down.'),
    ('24000000-0000-0000-0000-000000000015', 'G3-ROUND-01', 'ROUNDING', 3, 'Round 85 to the nearest ten.', 1, '85 is exactly between 80 and 90, and rounds up to 90.', 'When the ones digit is 5, round up.'),

    ('24000000-0000-0000-0000-000000000016', 'G3-TIME-01', 'TIME_MINUTE', 1, 'The long hand points to the 3. How many minutes past the hour is it?', 1, 'Each number on the clock face is 5 minutes, so 3 x 5 = 15 minutes.', 'Multiply the number the long hand points to by 5.'),
    ('24000000-0000-0000-0000-000000000017', 'G3-TIME-01', 'TIME_MINUTE', 2, 'The long hand points to the 6. How many minutes past the hour is it?', 1, '6 x 5 = 30 minutes.', 'Multiply the number the long hand points to by 5.'),
    ('24000000-0000-0000-0000-000000000018', 'G3-TIME-01', 'TIME_MINUTE', 3, 'The long hand points to the 9. How many minutes past the hour is it?', 1, '9 x 5 = 45 minutes.', 'Multiply the number the long hand points to by 5.'),

    ('24000000-0000-0000-0000-000000000019', 'G3-GRAPH-01', 'BAR_GRAPHS', 1, 'A bar graph shows Monday: 5 books, Tuesday: 8 books. Which day had more books read?', 1, 'Tuesday''s bar is taller (8 is more than 5).', 'Compare the two numbers.'),
    ('24000000-0000-0000-0000-000000000020', 'G3-GRAPH-01', 'BAR_GRAPHS', 2, 'If a bar reaches up to the number 6 on a graph, how many does it represent?', 1, 'A bar reaching 6 represents the value 6.', 'Read straight across from the top of the bar to the scale.'),
    ('24000000-0000-0000-0000-000000000021', 'G3-GRAPH-01', 'BAR_GRAPHS', 3, 'A graph shows Red: 4, Blue: 7, Green: 2. Which color has the least?', 2, 'Green has the smallest number, 2.', 'Find the shortest bar.'),

    ('24000000-0000-0000-0000-000000000022', 'G3-MULTIDIGIT-01', 'MULTIDIGIT_ADDSUB', 1, 'What is 247 + 125?', 1, '247 + 125 = 372.', 'Add the ones, then the tens, then the hundreds.'),
    ('24000000-0000-0000-0000-000000000023', 'G3-MULTIDIGIT-01', 'MULTIDIGIT_ADDSUB', 2, 'What is 500 - 237?', 1, '500 - 237 = 263.', 'Try subtracting 200 first, then 37 more.'),
    ('24000000-0000-0000-0000-000000000024', 'G3-MULTIDIGIT-01', 'MULTIDIGIT_ADDSUB', 3, 'What is 356 + 289?', 1, '356 + 289 = 645.', 'Add the ones first and carry over as needed.'),

    ('24000000-0000-0000-0000-000000000025', 'G3-WORD-01', 'WORD_PROB_G3', 1, 'There are 4 bags with 6 apples each. How many apples in total?', 1, '4 x 6 = 24 apples.', 'Multiply the number of bags by the apples in each.'),
    ('24000000-0000-0000-0000-000000000026', 'G3-WORD-01', 'WORD_PROB_G3', 2, '24 cookies are shared equally among 6 friends. How many cookies does each friend get?', 1, '24 / 6 = 4 cookies each.', 'Divide the total cookies by the number of friends.'),
    ('24000000-0000-0000-0000-000000000027', 'G3-WORD-01', 'WORD_PROB_G3', 3, 'A farmer has 5 rows of 7 plants. How many plants in total?', 1, '5 x 7 = 35 plants.', 'Multiply the number of rows by the plants in each row.'),

    ('24000000-0000-0000-0000-000000000028', 'G3-ENG-COMP-01', 'COMPREHENSION_G3', 1, 'Read: "Jake wanted a puppy, but his family lived in a small apartment. His parents said they could get a cat instead." What pet will Jake probably get?', 1, 'The passage suggests Jake will get a cat since a puppy wasn''t possible.', 'Look for what the parents suggested instead.'),
    ('24000000-0000-0000-0000-000000000029', 'G3-ENG-COMP-01', 'COMPREHENSION_G3', 2, 'Read: "Ana practiced piano every day for a month before her recital. On the big day, she played perfectly." Why did Ana play perfectly?', 1, 'The passage says she practiced every day for a month.', 'Look for what Ana did before the recital.'),
    ('24000000-0000-0000-0000-000000000030', 'G3-ENG-COMP-01', 'COMPREHENSION_G3', 3, 'Read: "The campers set up their tent quickly because dark clouds were rolling in." Why did they hurry?', 1, 'The passage says dark clouds were rolling in, meaning rain was coming.', 'Look for what the dark clouds suggest.'),

    ('24000000-0000-0000-0000-000000000031', 'G3-ENG-CONTEXT-01', 'CONTEXT_CLUES', 1, '"The arid desert had not seen rain in months." What does "arid" most likely mean?', 1, '"Arid" means very dry, which fits a desert with no rain.', 'Think about what a desert with no rain would be like.'),
    ('24000000-0000-0000-0000-000000000032', 'G3-ENG-CONTEXT-01', 'CONTEXT_CLUES', 2, '"She was ecstatic when she won first place." What does "ecstatic" mean?', 1, '"Ecstatic" means extremely happy, which fits winning first place.', 'Think about how someone would feel after winning.'),
    ('24000000-0000-0000-0000-000000000033', 'G3-ENG-CONTEXT-01', 'CONTEXT_CLUES', 3, '"The ancient castle was built centuries ago." What does "ancient" mean?', 1, '"Ancient" means very old, which fits something built centuries ago.', 'Think about what "centuries ago" tells you about its age.'),

    ('24000000-0000-0000-0000-000000000034', 'G3-ENG-PREFIX-01', 'PREFIX_SUFFIX', 1, 'What does the prefix "re-" mean in "redo"?', 1, '"Re-" means "again," so "redo" means to do again.', 'Think of other words starting with "re-", like "return".'),
    ('24000000-0000-0000-0000-000000000035', 'G3-ENG-PREFIX-01', 'PREFIX_SUFFIX', 2, 'What does the suffix "-ful" mean in "helpful"?', 1, '"-ful" means "full of," so "helpful" means full of help.', 'Think of other words ending in "-ful", like "joyful".'),
    ('24000000-0000-0000-0000-000000000036', 'G3-ENG-PREFIX-01', 'PREFIX_SUFFIX', 3, 'What does the prefix "un-" mean in "unhappy"?', 2, '"Un-" means "not," so "unhappy" means not happy.', 'Think of other words starting with "un-", like "unfair".'),

    ('24000000-0000-0000-0000-000000000037', 'G3-ENG-POS-01', 'PARTS_OF_SPEECH_G3', 1, 'In "She ran quickly," which word is the adverb?', 2, '"Quickly" describes how she ran, so it is the adverb.', 'An adverb tells you how an action happens.'),
    ('24000000-0000-0000-0000-000000000038', 'G3-ENG-POS-01', 'PARTS_OF_SPEECH_G3', 2, 'Which word describes how an action happens?', 2, 'An adverb describes how an action happens.', 'Think of the part of speech that often ends in "-ly".'),
    ('24000000-0000-0000-0000-000000000039', 'G3-ENG-POS-01', 'PARTS_OF_SPEECH_G3', 3, 'In "He spoke softly," which word tells us how he spoke?', 2, '"Softly" tells us how he spoke, so it is the adverb.', 'Look for the word that describes the manner of speaking.'),

    ('24000000-0000-0000-0000-000000000040', 'G3-ENG-COMPARE-01', 'COMPARE_CONTRAST', 1, 'Dogs bark and cats meow. Both are pets. What is one difference between them?', 1, 'Dogs bark while cats meow — that is a difference.', 'Look for what is not the same between the two.'),
    ('24000000-0000-0000-0000-000000000041', 'G3-ENG-COMPARE-01', 'COMPARE_CONTRAST', 2, 'A bicycle has two wheels; a car has four. What do they have in common?', 0, 'Both a bicycle and a car have wheels.', 'Look for what both things share.'),
    ('24000000-0000-0000-0000-000000000042', 'G3-ENG-COMPARE-01', 'COMPARE_CONTRAST', 3, 'Summer is hot; winter is cold. What is similar about them?', 0, 'Summer and winter are both seasons.', 'Look for the category both things belong to.'),

    ('24000000-0000-0000-0000-000000000043', 'G3-ENG-CAUSE-01', 'CAUSE_EFFECT', 1, 'It rained all night, so the field was muddy in the morning. What caused the mud?', 1, 'The rain caused the field to become muddy.', 'Look for the event that happened first.'),
    ('24000000-0000-0000-0000-000000000044', 'G3-ENG-CAUSE-01', 'CAUSE_EFFECT', 2, 'Maria forgot her umbrella, so she got wet walking home. What was the effect?', 1, 'Getting wet was the effect of forgetting her umbrella.', 'Look for what happened as a result.'),
    ('24000000-0000-0000-0000-000000000045', 'G3-ENG-CAUSE-01', 'CAUSE_EFFECT', 3, 'The ice cream melted because it was left in the sun. Why did it melt?', 0, 'Being left in the sun caused the ice cream to melt.', 'Look for the reason given after "because".'),

    ('24000000-0000-0000-0000-000000000046', 'G3-ENG-FACTOP-01', 'FACT_OPINION', 1, 'Which sentence is a fact?', 1, 'Water freezing at 32 degrees Fahrenheit can be proven true.', 'A fact can be checked and proven.'),
    ('24000000-0000-0000-0000-000000000047', 'G3-ENG-FACTOP-01', 'FACT_OPINION', 2, 'Which sentence is an opinion?', 0, '"Dogs are better pets than cats" is a personal opinion, not provable.', 'An opinion is what someone believes, not a provable fact.'),
    ('24000000-0000-0000-0000-000000000048', 'G3-ENG-FACTOP-01', 'FACT_OPINION', 3, 'Which sentence can be proven true or false?', 1, '"The Earth orbits the Sun" can be proven true.', 'A fact can be checked with evidence.'),

    ('24000000-0000-0000-0000-000000000049', 'G3-ENG-SVA-01', 'SUBJECT_VERB', 1, 'Which sentence is correct?', 1, '"The dog runs fast" correctly matches a singular subject with "runs."', 'A singular subject (dog) needs a verb ending in "s".'),
    ('24000000-0000-0000-0000-000000000050', 'G3-ENG-SVA-01', 'SUBJECT_VERB', 2, 'Which sentence is correct?', 1, '"They play outside" correctly matches a plural subject with "play."', 'A plural subject (they) does not need a verb ending in "s".'),
    ('24000000-0000-0000-0000-000000000051', 'G3-ENG-SVA-01', 'SUBJECT_VERB', 3, 'Which sentence is correct?', 1, '"She likes pizza" correctly matches a singular subject with "likes."', 'A singular subject (she) needs a verb ending in "s".');

INSERT INTO exercise_choices (exercise_id, choice_index, choice_text) VALUES
    ('24000000-0000-0000-0000-000000000001', 0, '7'), ('24000000-0000-0000-0000-000000000001', 1, '12'), ('24000000-0000-0000-0000-000000000001', 2, '15'),
    ('24000000-0000-0000-0000-000000000002', 0, '7'), ('24000000-0000-0000-0000-000000000002', 1, '10'), ('24000000-0000-0000-0000-000000000002', 2, '12'),
    ('24000000-0000-0000-0000-000000000003', 0, '16'), ('24000000-0000-0000-0000-000000000003', 1, '18'), ('24000000-0000-0000-0000-000000000003', 2, '21'),

    ('24000000-0000-0000-0000-000000000004', 0, '3'), ('24000000-0000-0000-0000-000000000004', 1, '4'), ('24000000-0000-0000-0000-000000000004', 2, '5'),
    ('24000000-0000-0000-0000-000000000005', 0, '4'), ('24000000-0000-0000-0000-000000000005', 1, '5'), ('24000000-0000-0000-0000-000000000005', 2, '6'),
    ('24000000-0000-0000-0000-000000000006', 0, '2'), ('24000000-0000-0000-0000-000000000006', 1, '3'), ('24000000-0000-0000-0000-000000000006', 2, '4'),

    ('24000000-0000-0000-0000-000000000007', 0, '1/2'), ('24000000-0000-0000-0000-000000000007', 1, '1/4'), ('24000000-0000-0000-0000-000000000007', 2, '1/3'),
    ('24000000-0000-0000-0000-000000000008', 0, '1/2'), ('24000000-0000-0000-0000-000000000008', 1, '1/3'), ('24000000-0000-0000-0000-000000000008', 2, '1/4'),
    ('24000000-0000-0000-0000-000000000009', 0, 'A half'), ('24000000-0000-0000-0000-000000000009', 1, 'A third'), ('24000000-0000-0000-0000-000000000009', 2, 'A fourth'),

    ('24000000-0000-0000-0000-000000000010', 0, '7'), ('24000000-0000-0000-0000-000000000010', 1, '12'), ('24000000-0000-0000-0000-000000000010', 2, '14'),
    ('24000000-0000-0000-0000-000000000011', 0, '10'), ('24000000-0000-0000-0000-000000000011', 1, '20'), ('24000000-0000-0000-0000-000000000011', 2, '25'),
    ('24000000-0000-0000-0000-000000000012', 0, '8'), ('24000000-0000-0000-0000-000000000012', 1, '12'), ('24000000-0000-0000-0000-000000000012', 2, '16'),

    ('24000000-0000-0000-0000-000000000013', 0, '40'), ('24000000-0000-0000-0000-000000000013', 1, '50'), ('24000000-0000-0000-0000-000000000013', 2, '45'),
    ('24000000-0000-0000-0000-000000000014', 0, '20'), ('24000000-0000-0000-0000-000000000014', 1, '30'), ('24000000-0000-0000-0000-000000000014', 2, '25'),
    ('24000000-0000-0000-0000-000000000015', 0, '80'), ('24000000-0000-0000-0000-000000000015', 1, '90'), ('24000000-0000-0000-0000-000000000015', 2, '85'),

    ('24000000-0000-0000-0000-000000000016', 0, '3 minutes'), ('24000000-0000-0000-0000-000000000016', 1, '15 minutes'), ('24000000-0000-0000-0000-000000000016', 2, '30 minutes'),
    ('24000000-0000-0000-0000-000000000017', 0, '6 minutes'), ('24000000-0000-0000-0000-000000000017', 1, '30 minutes'), ('24000000-0000-0000-0000-000000000017', 2, '60 minutes'),
    ('24000000-0000-0000-0000-000000000018', 0, '9 minutes'), ('24000000-0000-0000-0000-000000000018', 1, '45 minutes'), ('24000000-0000-0000-0000-000000000018', 2, '90 minutes'),

    ('24000000-0000-0000-0000-000000000019', 0, 'Monday'), ('24000000-0000-0000-0000-000000000019', 1, 'Tuesday'), ('24000000-0000-0000-0000-000000000019', 2, 'Same'),
    ('24000000-0000-0000-0000-000000000020', 0, '5'), ('24000000-0000-0000-0000-000000000020', 1, '6'), ('24000000-0000-0000-0000-000000000020', 2, '7'),
    ('24000000-0000-0000-0000-000000000021', 0, 'Red'), ('24000000-0000-0000-0000-000000000021', 1, 'Blue'), ('24000000-0000-0000-0000-000000000021', 2, 'Green'),

    ('24000000-0000-0000-0000-000000000022', 0, '362'), ('24000000-0000-0000-0000-000000000022', 1, '372'), ('24000000-0000-0000-0000-000000000022', 2, '382'),
    ('24000000-0000-0000-0000-000000000023', 0, '253'), ('24000000-0000-0000-0000-000000000023', 1, '263'), ('24000000-0000-0000-0000-000000000023', 2, '273'),
    ('24000000-0000-0000-0000-000000000024', 0, '635'), ('24000000-0000-0000-0000-000000000024', 1, '645'), ('24000000-0000-0000-0000-000000000024', 2, '655'),

    ('24000000-0000-0000-0000-000000000025', 0, '10'), ('24000000-0000-0000-0000-000000000025', 1, '24'), ('24000000-0000-0000-0000-000000000025', 2, '20'),
    ('24000000-0000-0000-0000-000000000026', 0, '3'), ('24000000-0000-0000-0000-000000000026', 1, '4'), ('24000000-0000-0000-0000-000000000026', 2, '5'),
    ('24000000-0000-0000-0000-000000000027', 0, '30'), ('24000000-0000-0000-0000-000000000027', 1, '35'), ('24000000-0000-0000-0000-000000000027', 2, '40'),

    ('24000000-0000-0000-0000-000000000028', 0, 'A puppy'), ('24000000-0000-0000-0000-000000000028', 1, 'A cat'), ('24000000-0000-0000-0000-000000000028', 2, 'A bird'),
    ('24000000-0000-0000-0000-000000000029', 0, 'She got lucky'), ('24000000-0000-0000-0000-000000000029', 1, 'She practiced a lot'), ('24000000-0000-0000-0000-000000000029', 2, 'Her piano was special'),
    ('24000000-0000-0000-0000-000000000030', 0, 'They were tired'), ('24000000-0000-0000-0000-000000000030', 1, 'Rain was coming'), ('24000000-0000-0000-0000-000000000030', 2, 'It was getting dark'),

    ('24000000-0000-0000-0000-000000000031', 0, 'Wet'), ('24000000-0000-0000-0000-000000000031', 1, 'Dry'), ('24000000-0000-0000-0000-000000000031', 2, 'Cold'),
    ('24000000-0000-0000-0000-000000000032', 0, 'Very sad'), ('24000000-0000-0000-0000-000000000032', 1, 'Very happy'), ('24000000-0000-0000-0000-000000000032', 2, 'Very tired'),
    ('24000000-0000-0000-0000-000000000033', 0, 'New'), ('24000000-0000-0000-0000-000000000033', 1, 'Very old'), ('24000000-0000-0000-0000-000000000033', 2, 'Medium-sized'),

    ('24000000-0000-0000-0000-000000000034', 0, 'Not'), ('24000000-0000-0000-0000-000000000034', 1, 'Again'), ('24000000-0000-0000-0000-000000000034', 2, 'Before'),
    ('24000000-0000-0000-0000-000000000035', 0, 'Without'), ('24000000-0000-0000-0000-000000000035', 1, 'Full of'), ('24000000-0000-0000-0000-000000000035', 2, 'Before'),
    ('24000000-0000-0000-0000-000000000036', 0, 'Again'), ('24000000-0000-0000-0000-000000000036', 1, 'Very'), ('24000000-0000-0000-0000-000000000036', 2, 'Not'),

    ('24000000-0000-0000-0000-000000000037', 0, 'She'), ('24000000-0000-0000-0000-000000000037', 1, 'ran'), ('24000000-0000-0000-0000-000000000037', 2, 'quickly'),
    ('24000000-0000-0000-0000-000000000038', 0, 'Noun'), ('24000000-0000-0000-0000-000000000038', 1, 'Verb'), ('24000000-0000-0000-0000-000000000038', 2, 'Adverb'),
    ('24000000-0000-0000-0000-000000000039', 0, 'He'), ('24000000-0000-0000-0000-000000000039', 1, 'spoke'), ('24000000-0000-0000-0000-000000000039', 2, 'softly'),

    ('24000000-0000-0000-0000-000000000040', 0, 'Both are pets'), ('24000000-0000-0000-0000-000000000040', 1, 'Dogs bark, cats meow'), ('24000000-0000-0000-0000-000000000040', 2, 'Both have fur'),
    ('24000000-0000-0000-0000-000000000041', 0, 'Both have wheels'), ('24000000-0000-0000-0000-000000000041', 1, 'Both have engines'), ('24000000-0000-0000-0000-000000000041', 2, 'Both fly'),
    ('24000000-0000-0000-0000-000000000042', 0, 'Both are seasons'), ('24000000-0000-0000-0000-000000000042', 1, 'Both are hot'), ('24000000-0000-0000-0000-000000000042', 2, 'Both are cold'),

    ('24000000-0000-0000-0000-000000000043', 0, 'The sun'), ('24000000-0000-0000-0000-000000000043', 1, 'The rain'), ('24000000-0000-0000-0000-000000000043', 2, 'The wind'),
    ('24000000-0000-0000-0000-000000000044', 0, 'She forgot her umbrella'), ('24000000-0000-0000-0000-000000000044', 1, 'She got wet'), ('24000000-0000-0000-0000-000000000044', 2, 'It stopped raining'),
    ('24000000-0000-0000-0000-000000000045', 0, 'It was left in the sun'), ('24000000-0000-0000-0000-000000000045', 1, 'It was too cold'), ('24000000-0000-0000-0000-000000000045', 2, 'It was eaten'),

    ('24000000-0000-0000-0000-000000000046', 0, 'Ice cream is the best dessert.'), ('24000000-0000-0000-0000-000000000046', 1, 'Water freezes at 32 degrees Fahrenheit.'), ('24000000-0000-0000-0000-000000000046', 2, 'Summer is more fun than winter.'),
    ('24000000-0000-0000-0000-000000000047', 0, 'Dogs are better pets than cats.'), ('24000000-0000-0000-0000-000000000047', 1, 'Dogs have four legs.'), ('24000000-0000-0000-0000-000000000047', 2, 'Dogs bark.'),
    ('24000000-0000-0000-0000-000000000048', 0, 'Pizza tastes amazing.'), ('24000000-0000-0000-0000-000000000048', 1, 'The Earth orbits the Sun.'), ('24000000-0000-0000-0000-000000000048', 2, 'Blue is the prettiest color.'),

    ('24000000-0000-0000-0000-000000000049', 0, 'The dog run fast.'), ('24000000-0000-0000-0000-000000000049', 1, 'The dog runs fast.'), ('24000000-0000-0000-0000-000000000049', 2, 'The dog running fast.'),
    ('24000000-0000-0000-0000-000000000050', 0, 'They plays outside.'), ('24000000-0000-0000-0000-000000000050', 1, 'They play outside.'), ('24000000-0000-0000-0000-000000000050', 2, 'They playing outside.'),
    ('24000000-0000-0000-0000-000000000051', 0, 'She like pizza.'), ('24000000-0000-0000-0000-000000000051', 1, 'She likes pizza.'), ('24000000-0000-0000-0000-000000000051', 2, 'She liking pizza.');
