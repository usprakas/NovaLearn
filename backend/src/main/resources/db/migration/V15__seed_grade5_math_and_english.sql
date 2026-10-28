-- Grade 5 curriculum: 9 Math lessons + 8 English lessons.

INSERT INTO skills (code, subject_code, name) VALUES
    ('FRAC_ADDSUB', 'MATH', 'Adding and Subtracting Fractions'),
    ('FRAC_MULT', 'MATH', 'Multiplying Fractions'),
    ('DECIMAL_OPS', 'MATH', 'Decimal Operations'),
    ('VOLUME_G5', 'MATH', 'Volume'),
    ('COORD_PLANE', 'MATH', 'Coordinate Plane Introduction'),
    ('ORDER_OPS', 'MATH', 'Order of Operations'),
    ('PERCENT_INTRO', 'MATH', 'Percentages Introduction'),
    ('POWERS_10', 'MATH', 'Powers of 10'),
    ('WORD_PROB_G5', 'MATH', 'Multi-Step Word Problems'),
    ('COMPREHENSION_G5', 'ENGLISH', 'Reading Comprehension'),
    ('INFERENCE_G5', 'ENGLISH', 'Making Inferences'),
    ('THEME_SUMMARY', 'ENGLISH', 'Theme and Summary'),
    ('CLAUSES_G5', 'ENGLISH', 'Clauses'),
    ('ROOT_WORDS', 'ENGLISH', 'Root Words'),
    ('PERSUASIVE_INFORM', 'ENGLISH', 'Persuasive vs. Informative Text'),
    ('POETRY_BASICS', 'ENGLISH', 'Poetry Basics'),
    ('POINT_OF_VIEW', 'ENGLISH', 'Author''s Point of View');

INSERT INTO lessons (id, code, subject_code, grade_level, display_order, title, description) VALUES
    ('16000000-0000-0000-0000-000000000001', 'G5-FRACADDSUB-01', 'MATH', 'GRADE_5', 1, 'Adding and Subtracting Fractions', 'Combine fractions that already share a denominator.'),
    ('16000000-0000-0000-0000-000000000002', 'G5-FRACMULT-01', 'MATH', 'GRADE_5', 2, 'Multiplying Fractions', 'Multiply two fractions together.'),
    ('16000000-0000-0000-0000-000000000003', 'G5-DECIMALOPS-01', 'MATH', 'GRADE_5', 3, 'Decimal Operations', 'Add, subtract, and multiply decimal numbers.'),
    ('16000000-0000-0000-0000-000000000004', 'G5-VOLUME-01', 'MATH', 'GRADE_5', 4, 'Volume', 'Find how much space a box-shaped object takes up.'),
    ('16000000-0000-0000-0000-000000000005', 'G5-COORD-01', 'MATH', 'GRADE_5', 5, 'Coordinate Plane Introduction', 'Read and understand points on a grid.'),
    ('16000000-0000-0000-0000-000000000006', 'G5-ORDEROPS-01', 'MATH', 'GRADE_5', 6, 'Order of Operations', 'Solve expressions with more than one operation in the right order.'),
    ('16000000-0000-0000-0000-000000000007', 'G5-PERCENT-01', 'MATH', 'GRADE_5', 7, 'Percentages Introduction', 'Understand what percent means and find simple percentages.'),
    ('16000000-0000-0000-0000-000000000008', 'G5-POWERS10-01', 'MATH', 'GRADE_5', 8, 'Powers of 10', 'Multiply numbers by 10 repeatedly.'),
    ('16000000-0000-0000-0000-000000000009', 'G5-WORD-01', 'MATH', 'GRADE_5', 9, 'Multi-Step Word Problems', 'Solve real-world problems with decimals and multiple steps.'),
    ('16000000-0000-0000-0000-000000000010', 'G5-ENG-COMP-01', 'ENGLISH', 'GRADE_5', 1, 'Reading Comprehension', 'Draw conclusions from a more complex passage.'),
    ('16000000-0000-0000-0000-000000000011', 'G5-ENG-INFER-01', 'ENGLISH', 'GRADE_5', 2, 'Making Inferences', 'Figure out what isn''t directly stated.'),
    ('16000000-0000-0000-0000-000000000012', 'G5-ENG-THEME-01', 'ENGLISH', 'GRADE_5', 3, 'Theme and Summary', 'Find the central message of a story.'),
    ('16000000-0000-0000-0000-000000000013', 'G5-ENG-CLAUSE-01', 'ENGLISH', 'GRADE_5', 4, 'Clauses', 'Tell independent and dependent clauses apart.'),
    ('16000000-0000-0000-0000-000000000014', 'G5-ENG-ROOT-01', 'ENGLISH', 'GRADE_5', 5, 'Root Words', 'Use a word''s root to figure out its meaning.'),
    ('16000000-0000-0000-0000-000000000015', 'G5-ENG-PERSUADE-01', 'ENGLISH', 'GRADE_5', 6, 'Persuasive vs. Informative Text', 'Tell writing that convinces apart from writing that informs.'),
    ('16000000-0000-0000-0000-000000000016', 'G5-ENG-POETRY-01', 'ENGLISH', 'GRADE_5', 7, 'Poetry Basics', 'Recognize rhyme, stanzas, and repetition in poems.'),
    ('16000000-0000-0000-0000-000000000017', 'G5-ENG-POV-01', 'ENGLISH', 'GRADE_5', 8, 'Author''s Point of View', 'Tell first, second, and third person narration apart.');

INSERT INTO exercises (id, lesson_code, skill_code, display_order, prompt, answer_index, explanation, hint) VALUES
    ('26000000-0000-0000-0000-000000000001', 'G5-FRACADDSUB-01', 'FRAC_ADDSUB', 1, 'What is 1/4 + 2/4?', 1, '1/4 + 2/4 = 3/4.', 'Since the denominators match, just add the top numbers.'),
    ('26000000-0000-0000-0000-000000000002', 'G5-FRACADDSUB-01', 'FRAC_ADDSUB', 2, 'What is 3/5 - 1/5?', 0, '3/5 - 1/5 = 2/5.', 'Since the denominators match, just subtract the top numbers.'),
    ('26000000-0000-0000-0000-000000000003', 'G5-FRACADDSUB-01', 'FRAC_ADDSUB', 3, 'What is 1/2 + 1/4?', 1, '1/2 is the same as 2/4, so 2/4 + 1/4 = 3/4.', 'Rewrite 1/2 as 2/4 so both fractions share a denominator.'),

    ('26000000-0000-0000-0000-000000000004', 'G5-FRACMULT-01', 'FRAC_MULT', 1, 'What is 1/2 x 1/3?', 0, 'Multiply the tops (1x1=1) and the bottoms (2x3=6): 1/6.', 'Multiply straight across: top times top, bottom times bottom.'),
    ('26000000-0000-0000-0000-000000000005', 'G5-FRACMULT-01', 'FRAC_MULT', 2, 'What is 2/3 x 1/2?', 0, '2/3 x 1/2 = 2/6, which simplifies to 1/3.', 'Multiply straight across, then simplify.'),
    ('26000000-0000-0000-0000-000000000006', 'G5-FRACMULT-01', 'FRAC_MULT', 3, 'What is 3/4 x 2/3?', 0, '3/4 x 2/3 = 6/12, which simplifies to 1/2.', 'Multiply straight across, then simplify.'),

    ('26000000-0000-0000-0000-000000000007', 'G5-DECIMALOPS-01', 'DECIMAL_OPS', 1, 'What is 2.5 + 1.3?', 1, '2.5 + 1.3 = 3.8.', 'Line up the decimal points and add each column.'),
    ('26000000-0000-0000-0000-000000000008', 'G5-DECIMALOPS-01', 'DECIMAL_OPS', 2, 'What is 5.6 - 2.1?', 1, '5.6 - 2.1 = 3.5.', 'Line up the decimal points and subtract each column.'),
    ('26000000-0000-0000-0000-000000000009', 'G5-DECIMALOPS-01', 'DECIMAL_OPS', 3, 'What is 1.5 x 2?', 1, '1.5 x 2 = 3.0.', 'Multiply as if there were no decimal, then place it back.'),

    ('26000000-0000-0000-0000-000000000010', 'G5-VOLUME-01', 'VOLUME_G5', 1, 'A box is 2 units long, 3 units wide, and 4 units tall. What is its volume?', 1, 'Volume = 2 x 3 x 4 = 24.', 'Multiply length, width, and height together.'),
    ('26000000-0000-0000-0000-000000000011', 'G5-VOLUME-01', 'VOLUME_G5', 2, 'What formula finds the volume of a box?', 1, 'Volume = length x width x height.', 'Think about multiplying all three dimensions together.'),
    ('26000000-0000-0000-0000-000000000012', 'G5-VOLUME-01', 'VOLUME_G5', 3, 'A cube has sides of 3 units. What is its volume?', 2, 'Volume = 3 x 3 x 3 = 27.', 'A cube''s volume is its side length multiplied by itself three times.'),

    ('26000000-0000-0000-0000-000000000013', 'G5-COORD-01', 'COORD_PLANE', 1, 'On a coordinate plane, which number tells you how far right or left to go?', 0, 'The x-coordinate tells you the left-right position.', 'Remember: x comes before y, and "x" sounds like "cross" the page.'),
    ('26000000-0000-0000-0000-000000000014', 'G5-COORD-01', 'COORD_PLANE', 2, 'What is the point (0,0) called?', 0, 'The point (0,0) is called the origin.', 'This is the point where the two axis lines cross.'),
    ('26000000-0000-0000-0000-000000000015', 'G5-COORD-01', 'COORD_PLANE', 3, 'In the point (3,5), which number tells you how far up to go?', 1, 'The second number, 5, is the y-coordinate and tells you how far up.', 'The second number in the pair is always the y-coordinate.'),

    ('26000000-0000-0000-0000-000000000016', 'G5-ORDEROPS-01', 'ORDER_OPS', 1, 'What is 2 + 3 x 4?', 1, 'Multiply first: 3x4=12, then add: 2+12=14.', 'Multiplication happens before addition.'),
    ('26000000-0000-0000-0000-000000000017', 'G5-ORDEROPS-01', 'ORDER_OPS', 2, 'What is (2 + 3) x 4?', 0, 'Parentheses first: 2+3=5, then multiply: 5x4=20.', 'Always solve what is inside parentheses first.'),
    ('26000000-0000-0000-0000-000000000018', 'G5-ORDEROPS-01', 'ORDER_OPS', 3, 'What is 10 - 2 x 3?', 1, 'Multiply first: 2x3=6, then subtract: 10-6=4.', 'Multiplication happens before subtraction.'),

    ('26000000-0000-0000-0000-000000000019', 'G5-PERCENT-01', 'PERCENT_INTRO', 1, 'What does 50% mean?', 0, '50% means half of something.', 'Think of 50 out of 100 — half of the whole.'),
    ('26000000-0000-0000-0000-000000000020', 'G5-PERCENT-01', 'PERCENT_INTRO', 2, 'What is 100% of a number?', 2, '100% means the whole amount — all of it.', 'Think of 100 out of 100 — the entire whole.'),
    ('26000000-0000-0000-0000-000000000021', 'G5-PERCENT-01', 'PERCENT_INTRO', 3, 'If you get 25% off a $20 item, how much is the discount?', 0, '25% of 20 is 5, since 20 divided by 4 is 5.', '25% is the same as one-fourth.'),

    ('26000000-0000-0000-0000-000000000022', 'G5-POWERS10-01', 'POWERS_10', 1, 'What is 10 x 10?', 1, '10 x 10 = 100.', 'Each extra 10 adds another zero.'),
    ('26000000-0000-0000-0000-000000000023', 'G5-POWERS10-01', 'POWERS_10', 2, 'What is 10 x 10 x 10?', 1, '10 x 10 x 10 = 1000.', 'Each extra 10 adds another zero.'),
    ('26000000-0000-0000-0000-000000000024', 'G5-POWERS10-01', 'POWERS_10', 3, 'What is 100 x 10?', 1, '100 x 10 = 1000.', 'Multiplying by 10 adds one zero to the end.'),

    ('26000000-0000-0000-0000-000000000025', 'G5-WORD-01', 'WORD_PROB_G5', 1, 'A recipe needs 2.5 cups of flour for 1 batch. How much flour for 3 batches?', 2, '2.5 x 3 = 7.5 cups.', 'Multiply the flour needed for one batch by the number of batches.'),
    ('26000000-0000-0000-0000-000000000026', 'G5-WORD-01', 'WORD_PROB_G5', 2, 'A school has 240 students split evenly into 8 classes. If 2 more students join one class, how many are in that class?', 1, '240 / 8 = 30, then 30 + 2 = 32.', 'First divide to find the class size, then add the new students.'),
    ('26000000-0000-0000-0000-000000000027', 'G5-WORD-01', 'WORD_PROB_G5', 3, 'A train travels 60 miles in 1 hour. How far does it travel in 3.5 hours?', 2, '60 x 3.5 = 210 miles.', 'Multiply the speed by the number of hours.'),

    ('26000000-0000-0000-0000-000000000028', 'G5-ENG-COMP-01', 'COMPREHENSION_G5', 1, 'Read: "Despite years of training, the astronaut felt a wave of nerves as the rocket counted down." What does this suggest about the astronaut?', 1, 'Even with years of training, she still felt nervous, showing that fear can affect anyone.', 'Think about what "despite years of training" suggests.'),
    ('26000000-0000-0000-0000-000000000029', 'G5-ENG-COMP-01', 'COMPREHENSION_G5', 2, 'Read: "The old house creaked with every step, and dust covered every surface — no one had lived there in years." What can you conclude?', 1, 'The dust and creaking suggest the house has been empty for a long time.', 'Look for clues about how long the house has been empty.'),
    ('26000000-0000-0000-0000-000000000030', 'G5-ENG-COMP-01', 'COMPREHENSION_G5', 3, 'Read: "The scientist repeated the experiment five times before trusting the result." What does this show about the scientist?', 1, 'Repeating the experiment shows careful, thorough work.', 'Think about why someone would repeat something multiple times.'),

    ('26000000-0000-0000-0000-000000000031', 'G5-ENG-INFER-01', 'INFERENCE_G5', 1, 'Maria''s hands were shaking as she opened the envelope with her test results. What can you infer?', 1, 'Shaking hands suggest she was nervous about the results.', 'Think about what shaking hands usually mean.'),
    ('26000000-0000-0000-0000-000000000032', 'G5-ENG-INFER-01', 'INFERENCE_G5', 2, 'The dog''s tail wagged furiously when its owner walked in. What can you infer?', 1, 'A wagging tail usually means the dog is excited and happy.', 'Think about what dogs do when they are happy.'),
    ('26000000-0000-0000-0000-000000000033', 'G5-ENG-INFER-01', 'INFERENCE_G5', 3, 'Every light in the house was off and the car was gone. What can you infer?', 1, 'No lights and no car suggest no one is currently home.', 'Think about what these clues suggest together.'),

    ('26000000-0000-0000-0000-000000000034', 'G5-ENG-THEME-01', 'THEME_SUMMARY', 1, 'A story about a turtle who loses a race but keeps trying until he succeeds has what theme?', 1, 'The story''s theme is that perseverance pays off.', 'Think about the lesson the turtle''s actions teach.'),
    ('26000000-0000-0000-0000-000000000035', 'G5-ENG-THEME-01', 'THEME_SUMMARY', 2, 'What is a "theme" in a story?', 1, 'A theme is the central message or lesson of a story.', 'A theme is bigger than just what happens — it is what it means.'),
    ('26000000-0000-0000-0000-000000000036', 'G5-ENG-THEME-01', 'THEME_SUMMARY', 3, 'A fable where a greedy dog loses his bone by being greedy teaches what theme?', 0, 'The theme is that greed can cost you what you already have.', 'Think about what the dog lost because of his greed.'),

    ('26000000-0000-0000-0000-000000000037', 'G5-ENG-CLAUSE-01', 'CLAUSES_G5', 1, 'In "Because it rained, we stayed inside," which part is the dependent clause?', 0, '"Because it rained" cannot stand alone, so it is the dependent clause.', 'A dependent clause cannot be a complete sentence by itself.'),
    ('26000000-0000-0000-0000-000000000038', 'G5-ENG-CLAUSE-01', 'CLAUSES_G5', 2, 'What makes a clause "independent"?', 0, 'An independent clause can stand alone as a complete sentence.', 'Think about what "independent" means — not relying on anything else.'),
    ('26000000-0000-0000-0000-000000000039', 'G5-ENG-CLAUSE-01', 'CLAUSES_G5', 3, 'In "I ate breakfast before I left," which part could stand alone as a sentence?', 1, '"I ate breakfast" is a complete thought and could stand alone.', 'Look for the part that makes full sense by itself.'),

    ('26000000-0000-0000-0000-000000000040', 'G5-ENG-ROOT-01', 'ROOT_WORDS', 1, 'What is the root word in "unhappiness"?', 1, 'The root word is "happy" — "un-" and "-ness" are added to it.', 'Remove the prefix and suffix to find the root.'),
    ('26000000-0000-0000-0000-000000000041', 'G5-ENG-ROOT-01', 'ROOT_WORDS', 2, 'What is the root word in "replaying"?', 1, 'The root word is "play" — "re-" and "-ing" are added to it.', 'Remove the prefix and suffix to find the root.'),
    ('26000000-0000-0000-0000-000000000042', 'G5-ENG-ROOT-01', 'ROOT_WORDS', 3, 'Knowing the root "port" means "carry," what might "transport" mean?', 0, '"Trans-" means across, so "transport" likely means to carry across.', 'Combine the meaning of the prefix with the root''s meaning.'),

    ('26000000-0000-0000-0000-000000000043', 'G5-ENG-PERSUADE-01', 'PERSUASIVE_INFORM', 1, '"You should recycle because it protects our planet for future generations" is what type of text?', 0, 'This tries to convince you to act, making it persuasive.', 'Look for language that tries to change your behavior.'),
    ('26000000-0000-0000-0000-000000000044', 'G5-ENG-PERSUADE-01', 'PERSUASIVE_INFORM', 2, '"Recycling turns used materials into new products" is what type of text?', 1, 'This states a fact without trying to convince, making it informative.', 'Look for language that simply explains how something works.'),
    ('26000000-0000-0000-0000-000000000045', 'G5-ENG-PERSUADE-01', 'PERSUASIVE_INFORM', 3, 'Persuasive writing is mainly trying to:', 1, 'Persuasive writing tries to convince the reader of something.', 'Think about the goal behind persuasive writing.'),

    ('26000000-0000-0000-0000-000000000046', 'G5-ENG-POETRY-01', 'POETRY_BASICS', 1, 'What do we call words at the end of lines that sound alike?', 0, 'Words that sound alike at the end of lines are called rhymes.', 'Think about words like "cat" and "hat".'),
    ('26000000-0000-0000-0000-000000000047', 'G5-ENG-POETRY-01', 'POETRY_BASICS', 2, 'What is a "stanza" in a poem?', 1, 'A stanza is a group of lines, similar to a paragraph in prose.', 'Think of it like a paragraph, but in a poem.'),
    ('26000000-0000-0000-0000-000000000048', 'G5-ENG-POETRY-01', 'POETRY_BASICS', 3, 'Repeating "the wind, the wind, the wind" is an example of what?', 1, 'Saying the same words again is called repetition.', 'Think about what the word "repeat" means.'),

    ('26000000-0000-0000-0000-000000000049', 'G5-ENG-POV-01', 'POINT_OF_VIEW', 1, 'A story told using "I" and "me" is written in what point of view?', 0, 'Using "I" and "me" means the story is told in first person.', 'First person uses words like "I," "me," and "my".'),
    ('26000000-0000-0000-0000-000000000050', 'G5-ENG-POV-01', 'POINT_OF_VIEW', 2, 'A story told using "he," "she," and "they" is written in what point of view?', 2, 'Using "he," "she," and "they" means the story is told in third person.', 'Third person uses words like "he," "she," and "they".'),
    ('26000000-0000-0000-0000-000000000051', 'G5-ENG-POV-01', 'POINT_OF_VIEW', 3, 'In first person point of view, the narrator is:', 0, 'In first person, the narrator is a character inside the story.', 'Think about who is telling the story when "I" is used.');

INSERT INTO exercise_choices (exercise_id, choice_index, choice_text) VALUES
    ('26000000-0000-0000-0000-000000000001', 0, '1/4'), ('26000000-0000-0000-0000-000000000001', 1, '3/4'), ('26000000-0000-0000-0000-000000000001', 2, '3/8'),
    ('26000000-0000-0000-0000-000000000002', 0, '2/5'), ('26000000-0000-0000-0000-000000000002', 1, '2/10'), ('26000000-0000-0000-0000-000000000002', 2, '4/5'),
    ('26000000-0000-0000-0000-000000000003', 0, '2/6'), ('26000000-0000-0000-0000-000000000003', 1, '3/4'), ('26000000-0000-0000-0000-000000000003', 2, '1/6'),

    ('26000000-0000-0000-0000-000000000004', 0, '1/6'), ('26000000-0000-0000-0000-000000000004', 1, '1/5'), ('26000000-0000-0000-0000-000000000004', 2, '2/3'),
    ('26000000-0000-0000-0000-000000000005', 0, '1/3'), ('26000000-0000-0000-0000-000000000005', 1, '2/5'), ('26000000-0000-0000-0000-000000000005', 2, '3/6'),
    ('26000000-0000-0000-0000-000000000006', 0, '1/2'), ('26000000-0000-0000-0000-000000000006', 1, '5/7'), ('26000000-0000-0000-0000-000000000006', 2, '3/4'),

    ('26000000-0000-0000-0000-000000000007', 0, '3.7'), ('26000000-0000-0000-0000-000000000007', 1, '3.8'), ('26000000-0000-0000-0000-000000000007', 2, '3.9'),
    ('26000000-0000-0000-0000-000000000008', 0, '3.4'), ('26000000-0000-0000-0000-000000000008', 1, '3.5'), ('26000000-0000-0000-0000-000000000008', 2, '3.6'),
    ('26000000-0000-0000-0000-000000000009', 0, '2.5'), ('26000000-0000-0000-0000-000000000009', 1, '3.0'), ('26000000-0000-0000-0000-000000000009', 2, '3.5'),

    ('26000000-0000-0000-0000-000000000010', 0, '9'), ('26000000-0000-0000-0000-000000000010', 1, '24'), ('26000000-0000-0000-0000-000000000010', 2, '20'),
    ('26000000-0000-0000-0000-000000000011', 0, 'length + width + height'), ('26000000-0000-0000-0000-000000000011', 1, 'length x width x height'), ('26000000-0000-0000-0000-000000000011', 2, 'length x width'),
    ('26000000-0000-0000-0000-000000000012', 0, '9'), ('26000000-0000-0000-0000-000000000012', 1, '18'), ('26000000-0000-0000-0000-000000000012', 2, '27'),

    ('26000000-0000-0000-0000-000000000013', 0, 'x-coordinate'), ('26000000-0000-0000-0000-000000000013', 1, 'y-coordinate'), ('26000000-0000-0000-0000-000000000013', 2, 'Both'),
    ('26000000-0000-0000-0000-000000000014', 0, 'The origin'), ('26000000-0000-0000-0000-000000000014', 1, 'The center'), ('26000000-0000-0000-0000-000000000014', 2, 'The axis'),
    ('26000000-0000-0000-0000-000000000015', 0, '3'), ('26000000-0000-0000-0000-000000000015', 1, '5'), ('26000000-0000-0000-0000-000000000015', 2, 'Neither'),

    ('26000000-0000-0000-0000-000000000016', 0, '20'), ('26000000-0000-0000-0000-000000000016', 1, '14'), ('26000000-0000-0000-0000-000000000016', 2, '9'),
    ('26000000-0000-0000-0000-000000000017', 0, '20'), ('26000000-0000-0000-0000-000000000017', 1, '14'), ('26000000-0000-0000-0000-000000000017', 2, '9'),
    ('26000000-0000-0000-0000-000000000018', 0, '24'), ('26000000-0000-0000-0000-000000000018', 1, '4'), ('26000000-0000-0000-0000-000000000018', 2, '8'),

    ('26000000-0000-0000-0000-000000000019', 0, 'Half'), ('26000000-0000-0000-0000-000000000019', 1, 'A quarter'), ('26000000-0000-0000-0000-000000000019', 2, 'All of it'),
    ('26000000-0000-0000-0000-000000000020', 0, 'Half of it'), ('26000000-0000-0000-0000-000000000020', 1, 'None of it'), ('26000000-0000-0000-0000-000000000020', 2, 'All of it'),
    ('26000000-0000-0000-0000-000000000021', 0, '5'), ('26000000-0000-0000-0000-000000000021', 1, '10'), ('26000000-0000-0000-0000-000000000021', 2, '15'),

    ('26000000-0000-0000-0000-000000000022', 0, '20'), ('26000000-0000-0000-0000-000000000022', 1, '100'), ('26000000-0000-0000-0000-000000000022', 2, '1000'),
    ('26000000-0000-0000-0000-000000000023', 0, '100'), ('26000000-0000-0000-0000-000000000023', 1, '1000'), ('26000000-0000-0000-0000-000000000023', 2, '10000'),
    ('26000000-0000-0000-0000-000000000024', 0, '100'), ('26000000-0000-0000-0000-000000000024', 1, '1000'), ('26000000-0000-0000-0000-000000000024', 2, '10000'),

    ('26000000-0000-0000-0000-000000000025', 0, '5.5'), ('26000000-0000-0000-0000-000000000025', 1, '7.0'), ('26000000-0000-0000-0000-000000000025', 2, '7.5'),
    ('26000000-0000-0000-0000-000000000026', 0, '30'), ('26000000-0000-0000-0000-000000000026', 1, '32'), ('26000000-0000-0000-0000-000000000026', 2, '34'),
    ('26000000-0000-0000-0000-000000000027', 0, '180'), ('26000000-0000-0000-0000-000000000027', 1, '200'), ('26000000-0000-0000-0000-000000000027', 2, '210'),

    ('26000000-0000-0000-0000-000000000028', 0, 'She was not prepared'), ('26000000-0000-0000-0000-000000000028', 1, 'Even experienced people can feel nervous'), ('26000000-0000-0000-0000-000000000028', 2, 'She wanted to quit'),
    ('26000000-0000-0000-0000-000000000029', 0, 'The house is new'), ('26000000-0000-0000-0000-000000000029', 1, 'The house is abandoned'), ('26000000-0000-0000-0000-000000000029', 2, 'The house is clean'),
    ('26000000-0000-0000-0000-000000000030', 0, 'She was careless'), ('26000000-0000-0000-0000-000000000030', 1, 'She was thorough and careful'), ('26000000-0000-0000-0000-000000000030', 2, 'She didn''t understand the experiment'),

    ('26000000-0000-0000-0000-000000000031', 0, 'She was bored'), ('26000000-0000-0000-0000-000000000031', 1, 'She was nervous'), ('26000000-0000-0000-0000-000000000031', 2, 'She was angry'),
    ('26000000-0000-0000-0000-000000000032', 0, 'The dog was scared'), ('26000000-0000-0000-0000-000000000032', 1, 'The dog was excited'), ('26000000-0000-0000-0000-000000000032', 2, 'The dog was tired'),
    ('26000000-0000-0000-0000-000000000033', 0, 'Someone is home'), ('26000000-0000-0000-0000-000000000033', 1, 'No one is home'), ('26000000-0000-0000-0000-000000000033', 2, 'It is daytime'),

    ('26000000-0000-0000-0000-000000000034', 0, 'Giving up is easy'), ('26000000-0000-0000-0000-000000000034', 1, 'Perseverance pays off'), ('26000000-0000-0000-0000-000000000034', 2, 'Races are fun'),
    ('26000000-0000-0000-0000-000000000035', 0, 'A list of characters'), ('26000000-0000-0000-0000-000000000035', 1, 'The central message or lesson'), ('26000000-0000-0000-0000-000000000035', 2, 'The setting'),
    ('26000000-0000-0000-0000-000000000036', 0, 'Greed can cost you'), ('26000000-0000-0000-0000-000000000036', 1, 'Dogs like bones'), ('26000000-0000-0000-0000-000000000036', 2, 'Sharing is hard'),

    ('26000000-0000-0000-0000-000000000037', 0, 'Because it rained'), ('26000000-0000-0000-0000-000000000037', 1, 'we stayed inside'), ('26000000-0000-0000-0000-000000000037', 2, 'inside'),
    ('26000000-0000-0000-0000-000000000038', 0, 'It can stand alone as a sentence'), ('26000000-0000-0000-0000-000000000038', 1, 'It always starts with "because"'), ('26000000-0000-0000-0000-000000000038', 2, 'It has no verb'),
    ('26000000-0000-0000-0000-000000000039', 0, 'before I left'), ('26000000-0000-0000-0000-000000000039', 1, 'I ate breakfast'), ('26000000-0000-0000-0000-000000000039', 2, 'breakfast'),

    ('26000000-0000-0000-0000-000000000040', 0, 'un'), ('26000000-0000-0000-0000-000000000040', 1, 'happy'), ('26000000-0000-0000-0000-000000000040', 2, 'ness'),
    ('26000000-0000-0000-0000-000000000041', 0, 're'), ('26000000-0000-0000-0000-000000000041', 1, 'play'), ('26000000-0000-0000-0000-000000000041', 2, 'ing'),
    ('26000000-0000-0000-0000-000000000042', 0, 'To carry across'), ('26000000-0000-0000-0000-000000000042', 1, 'To stop carrying'), ('26000000-0000-0000-0000-000000000042', 2, 'To carry up'),

    ('26000000-0000-0000-0000-000000000043', 0, 'Persuasive'), ('26000000-0000-0000-0000-000000000043', 1, 'Informative'), ('26000000-0000-0000-0000-000000000043', 2, 'Narrative'),
    ('26000000-0000-0000-0000-000000000044', 0, 'Persuasive'), ('26000000-0000-0000-0000-000000000044', 1, 'Informative'), ('26000000-0000-0000-0000-000000000044', 2, 'Narrative'),
    ('26000000-0000-0000-0000-000000000045', 0, 'Tell a story'), ('26000000-0000-0000-0000-000000000045', 1, 'Convince you of something'), ('26000000-0000-0000-0000-000000000045', 2, 'List facts only'),

    ('26000000-0000-0000-0000-000000000046', 0, 'Rhyme'), ('26000000-0000-0000-0000-000000000046', 1, 'Rhythm'), ('26000000-0000-0000-0000-000000000046', 2, 'Repetition'),
    ('26000000-0000-0000-0000-000000000047', 0, 'A single word'), ('26000000-0000-0000-0000-000000000047', 1, 'A group of lines, like a paragraph'), ('26000000-0000-0000-0000-000000000047', 2, 'The title'),
    ('26000000-0000-0000-0000-000000000048', 0, 'Rhyme'), ('26000000-0000-0000-0000-000000000048', 1, 'Repetition'), ('26000000-0000-0000-0000-000000000048', 2, 'Rhythm'),

    ('26000000-0000-0000-0000-000000000049', 0, 'First person'), ('26000000-0000-0000-0000-000000000049', 1, 'Second person'), ('26000000-0000-0000-0000-000000000049', 2, 'Third person'),
    ('26000000-0000-0000-0000-000000000050', 0, 'First person'), ('26000000-0000-0000-0000-000000000050', 1, 'Second person'), ('26000000-0000-0000-0000-000000000050', 2, 'Third person'),
    ('26000000-0000-0000-0000-000000000051', 0, 'A character in the story'), ('26000000-0000-0000-0000-000000000051', 1, 'Not part of the story'), ('26000000-0000-0000-0000-000000000051', 2, 'Always the author');
