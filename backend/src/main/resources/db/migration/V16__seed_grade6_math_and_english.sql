-- Grade 6 curriculum: 9 Math lessons + 8 English lessons — the last of the PRE_K-GRADE_6 batch.

INSERT INTO skills (code, subject_code, name) VALUES
    ('RATIOS_RATES', 'MATH', 'Ratios and Rates'),
    ('PERCENT_G6', 'MATH', 'Percentages'),
    ('NEGATIVE_NUM', 'MATH', 'Negative Numbers'),
    ('ALGEBRA_EXPR', 'MATH', 'Basic Algebra Expressions'),
    ('ONE_STEP_EQ', 'MATH', 'One-Step Equations'),
    ('STATISTICS_BASIC', 'MATH', 'Statistics: Mean, Median, and Mode'),
    ('AREA_COMPLEX', 'MATH', 'Area of Complex Shapes'),
    ('COORD_GEOMETRY', 'MATH', 'Coordinate Geometry'),
    ('WORD_PROB_G6', 'MATH', 'Ratio and Percentage Word Problems'),
    ('COMPREHENSION_G6', 'ENGLISH', 'Reading Comprehension'),
    ('LITERARY_DEVICES', 'ENGLISH', 'Literary Devices'),
    ('ARGUMENT_EVIDENCE', 'ENGLISH', 'Argument and Evidence'),
    ('COMPLEX_SENTENCES', 'ENGLISH', 'Complex Sentences'),
    ('VOCAB_G6', 'ENGLISH', 'Academic Vocabulary'),
    ('TEXT_ANALYSIS', 'ENGLISH', 'Text Analysis'),
    ('RESEARCH_SKILLS', 'ENGLISH', 'Research Skills'),
    ('SUMMARIZE_PARAPHRASE', 'ENGLISH', 'Summarizing and Paraphrasing');

INSERT INTO lessons (id, code, subject_code, grade_level, display_order, title, description) VALUES
    ('17000000-0000-0000-0000-000000000001', 'G6-RATIO-01', 'MATH', 'GRADE_6', 1, 'Ratios and Rates', 'Compare quantities using ratios and rates.'),
    ('17000000-0000-0000-0000-000000000002', 'G6-PERCENT-01', 'MATH', 'GRADE_6', 2, 'Percentages', 'Find a percentage of a number.'),
    ('17000000-0000-0000-0000-000000000003', 'G6-NEGNUM-01', 'MATH', 'GRADE_6', 3, 'Negative Numbers', 'Add, subtract, and compare negative numbers.'),
    ('17000000-0000-0000-0000-000000000004', 'G6-ALGEBRA-01', 'MATH', 'GRADE_6', 4, 'Basic Algebra Expressions', 'Evaluate an expression when you know the value of its variable.'),
    ('17000000-0000-0000-0000-000000000005', 'G6-ONESTEP-01', 'MATH', 'GRADE_6', 5, 'One-Step Equations', 'Solve for an unknown value in a simple equation.'),
    ('17000000-0000-0000-0000-000000000006', 'G6-STATS-01', 'MATH', 'GRADE_6', 6, 'Statistics: Mean, Median, and Mode', 'Find the average, middle, and most common value in a data set.'),
    ('17000000-0000-0000-0000-000000000007', 'G6-AREACOMPLEX-01', 'MATH', 'GRADE_6', 7, 'Area of Complex Shapes', 'Find the area of shapes made from simpler pieces.'),
    ('17000000-0000-0000-0000-000000000008', 'G6-COORDGEO-01', 'MATH', 'GRADE_6', 8, 'Coordinate Geometry', 'Find distances and quadrants on a coordinate grid.'),
    ('17000000-0000-0000-0000-000000000009', 'G6-WORD-01', 'MATH', 'GRADE_6', 9, 'Ratio and Percentage Word Problems', 'Solve real-world problems using ratios and percentages.'),
    ('17000000-0000-0000-0000-000000000010', 'G6-ENG-COMP-01', 'ENGLISH', 'GRADE_6', 1, 'Reading Comprehension', 'Draw conclusions from longer, more complex passages.'),
    ('17000000-0000-0000-0000-000000000011', 'G6-ENG-LITDEVICE-01', 'ENGLISH', 'GRADE_6', 2, 'Literary Devices', 'Recognize personification, alliteration, and hyperbole.'),
    ('17000000-0000-0000-0000-000000000012', 'G6-ENG-ARGUMENT-01', 'ENGLISH', 'GRADE_6', 3, 'Argument and Evidence', 'Tell a strong claim and good evidence from a weak one.'),
    ('17000000-0000-0000-0000-000000000013', 'G6-ENG-COMPLEXSENT-01', 'ENGLISH', 'GRADE_6', 4, 'Complex Sentences', 'Identify sentences built from multiple clauses.'),
    ('17000000-0000-0000-0000-000000000014', 'G6-ENG-VOCAB-01', 'ENGLISH', 'GRADE_6', 5, 'Academic Vocabulary', 'Learn words used often in school writing.'),
    ('17000000-0000-0000-0000-000000000015', 'G6-ENG-TEXTANALYSIS-01', 'ENGLISH', 'GRADE_6', 6, 'Text Analysis', 'Think about an author''s choices and their effects.'),
    ('17000000-0000-0000-0000-000000000016', 'G6-ENG-RESEARCH-01', 'ENGLISH', 'GRADE_6', 7, 'Research Skills', 'Judge whether a source is reliable.'),
    ('17000000-0000-0000-0000-000000000017', 'G6-ENG-PARAPHRASE-01', 'ENGLISH', 'GRADE_6', 8, 'Summarizing and Paraphrasing', 'Restate ideas in your own words.');

INSERT INTO exercises (id, lesson_code, skill_code, display_order, prompt, answer_index, explanation, hint) VALUES
    ('27000000-0000-0000-0000-000000000001', 'G6-RATIO-01', 'RATIOS_RATES', 1, 'If there are 3 red marbles and 6 blue marbles, what is the ratio of red to blue in simplest form?', 0, '3:6 simplifies to 1:2 by dividing both numbers by 3.', 'Divide both numbers by their greatest common factor.'),
    ('27000000-0000-0000-0000-000000000002', 'G6-RATIO-01', 'RATIOS_RATES', 2, 'A car travels 120 miles in 2 hours. What is its rate in miles per hour?', 1, '120 / 2 = 60 miles per hour.', 'Divide the distance by the time.'),
    ('27000000-0000-0000-0000-000000000003', 'G6-RATIO-01', 'RATIOS_RATES', 3, 'If a recipe ratio is 2 cups flour to 1 cup sugar, how much flour is needed for 3 cups of sugar?', 1, 'The ratio 2:1 scaled up by 3 is 6:3, so 6 cups of flour.', 'Multiply both sides of the ratio by the same number.'),

    ('27000000-0000-0000-0000-000000000004', 'G6-PERCENT-01', 'PERCENT_G6', 1, 'What is 20% of 50?', 1, '20% of 50 is 10 (50 x 0.20 = 10).', 'Turn the percent into a decimal and multiply.'),
    ('27000000-0000-0000-0000-000000000005', 'G6-PERCENT-01', 'PERCENT_G6', 2, 'What is 75% of 80?', 1, '75% of 80 is 60 (80 x 0.75 = 60).', 'Turn the percent into a decimal and multiply.'),
    ('27000000-0000-0000-0000-000000000006', 'G6-PERCENT-01', 'PERCENT_G6', 3, 'A shirt costs $40. It is 10% off. What is the discount amount?', 1, '10% of 40 is 4 (40 x 0.10 = 4).', 'Turn the percent into a decimal and multiply.'),

    ('27000000-0000-0000-0000-000000000007', 'G6-NEGNUM-01', 'NEGATIVE_NUM', 1, 'What is -3 + 5?', 0, '-3 + 5 = 2.', 'Think of starting at -3 on a number line and moving 5 steps right.'),
    ('27000000-0000-0000-0000-000000000008', 'G6-NEGNUM-01', 'NEGATIVE_NUM', 2, 'What is -4 - 2?', 0, '-4 - 2 = -6.', 'Think of starting at -4 on a number line and moving 2 more steps left.'),
    ('27000000-0000-0000-0000-000000000009', 'G6-NEGNUM-01', 'NEGATIVE_NUM', 3, 'Which number is smaller: -5 or -2?', 0, '-5 is smaller than -2 — the further left on the number line, the smaller.', 'On a number line, numbers further left are smaller.'),

    ('27000000-0000-0000-0000-000000000010', 'G6-ALGEBRA-01', 'ALGEBRA_EXPR', 1, 'If x = 3, what is x + 5?', 1, '3 + 5 = 8.', 'Replace x with 3 and add.'),
    ('27000000-0000-0000-0000-000000000011', 'G6-ALGEBRA-01', 'ALGEBRA_EXPR', 2, 'If y = 4, what is 2y?', 1, '2y means 2 times y, so 2 x 4 = 8.', 'A number right next to a letter means multiply.'),
    ('27000000-0000-0000-0000-000000000012', 'G6-ALGEBRA-01', 'ALGEBRA_EXPR', 3, 'What is the value of 3x when x = 5?', 1, '3 x 5 = 15.', 'Replace x with 5 and multiply by 3.'),

    ('27000000-0000-0000-0000-000000000013', 'G6-ONESTEP-01', 'ONE_STEP_EQ', 1, 'Solve for x: x + 4 = 10.', 1, 'Subtract 4 from both sides: x = 6.', 'Do the opposite of addition: subtract 4 from both sides.'),
    ('27000000-0000-0000-0000-000000000014', 'G6-ONESTEP-01', 'ONE_STEP_EQ', 2, 'Solve for x: x - 3 = 7.', 1, 'Add 3 to both sides: x = 10.', 'Do the opposite of subtraction: add 3 to both sides.'),
    ('27000000-0000-0000-0000-000000000015', 'G6-ONESTEP-01', 'ONE_STEP_EQ', 3, 'Solve for x: 2x = 12.', 1, 'Divide both sides by 2: x = 6.', 'Do the opposite of multiplication: divide both sides by 2.'),

    ('27000000-0000-0000-0000-000000000016', 'G6-STATS-01', 'STATISTICS_BASIC', 1, 'What is the mean (average) of 2, 4, 6?', 1, '(2+4+6) / 3 = 4.', 'Add all the numbers, then divide by how many there are.'),
    ('27000000-0000-0000-0000-000000000017', 'G6-STATS-01', 'STATISTICS_BASIC', 2, 'What is the median of 1, 3, 5, 7, 9?', 1, 'The median is the middle number when sorted: 5.', 'Put the numbers in order and find the middle one.'),
    ('27000000-0000-0000-0000-000000000018', 'G6-STATS-01', 'STATISTICS_BASIC', 3, 'What is the mode of 2, 2, 3, 4, 4, 4?', 2, 'The mode is the number that appears most often: 4 appears three times.', 'Find the number that repeats the most.'),

    ('27000000-0000-0000-0000-000000000019', 'G6-AREACOMPLEX-01', 'AREA_COMPLEX', 1, 'An L-shaped figure is made of a 4x3 rectangle and a 2x2 square. What is its total area?', 1, '4x3=12 plus 2x2=4 gives a total area of 16.', 'Find the area of each piece, then add them together.'),
    ('27000000-0000-0000-0000-000000000020', 'G6-AREACOMPLEX-01', 'AREA_COMPLEX', 2, 'A triangle has a base of 6 and a height of 4. What is its area?', 1, 'Area = 1/2 x base x height = 1/2 x 6 x 4 = 12.', 'A triangle''s area is half of base times height.'),
    ('27000000-0000-0000-0000-000000000021', 'G6-AREACOMPLEX-01', 'AREA_COMPLEX', 3, 'A shape is made of two rectangles: one 5x2 and one 3x2. What is the total area?', 1, '5x2=10 plus 3x2=6 gives a total area of 16.', 'Find the area of each piece, then add them together.'),

    ('27000000-0000-0000-0000-000000000022', 'G6-COORDGEO-01', 'COORD_GEOMETRY', 1, 'What is the distance between the points (2,3) and (2,7) on a grid?', 1, 'The x-values match, so just find the difference in y: 7-3=4.', 'When the x-values match, subtract the y-values.'),
    ('27000000-0000-0000-0000-000000000023', 'G6-COORDGEO-01', 'COORD_GEOMETRY', 2, 'Which quadrant is the point (-3,4) in?', 1, 'A negative x and positive y puts the point in Quadrant II.', 'Quadrant II is where x is negative and y is positive.'),
    ('27000000-0000-0000-0000-000000000024', 'G6-COORDGEO-01', 'COORD_GEOMETRY', 3, 'What is the distance between the points (1,1) and (5,1)?', 1, 'The y-values match, so just find the difference in x: 5-1=4.', 'When the y-values match, subtract the x-values.'),

    ('27000000-0000-0000-0000-000000000025', 'G6-WORD-01', 'WORD_PROB_G6', 1, 'A class has 12 boys and 18 girls. What is the ratio of boys to girls in simplest form?', 0, '12:18 simplifies to 2:3 by dividing both by 6.', 'Divide both numbers by their greatest common factor.'),
    ('27000000-0000-0000-0000-000000000026', 'G6-WORD-01', 'WORD_PROB_G6', 2, 'A store marks down a $60 jacket by 30%. What is the new price?', 2, '30% of 60 is 18, so the new price is 60 - 18 = 42.', 'Find the discount first, then subtract it from the original price.'),
    ('27000000-0000-0000-0000-000000000027', 'G6-WORD-01', 'WORD_PROB_G6', 3, 'If 8 out of 20 students walk to school, what percentage walk?', 1, '8/20 = 0.40 = 40%.', 'Divide the part by the whole, then turn it into a percent.'),

    ('27000000-0000-0000-0000-000000000028', 'G6-ENG-COMP-01', 'COMPREHENSION_G6', 1, 'Read: "Although the committee debated for hours, they ultimately could not reach a consensus and postponed the vote." What happened?', 1, 'The passage says they could not agree, so the vote was delayed.', 'Look for what happened after the long debate.'),
    ('27000000-0000-0000-0000-000000000029', 'G6-ENG-COMP-01', 'COMPREHENSION_G6', 2, 'Read: "The novelist spent a decade researching before writing a single word of her historical fiction." What does this reveal about her approach?', 1, 'Spending ten years researching shows she valued accuracy and careful preparation.', 'Think about what ten years of research suggests about her priorities.'),
    ('27000000-0000-0000-0000-000000000030', 'G6-ENG-COMP-01', 'COMPREHENSION_G6', 3, 'Read: "The city''s new policy aimed to reduce traffic, but commute times only grew worse." What can you conclude about the policy?', 1, 'Commute times getting worse shows the policy failed its goal.', 'Compare the policy''s goal to what actually happened.'),

    ('27000000-0000-0000-0000-000000000031', 'G6-ENG-LITDEVICE-01', 'LITERARY_DEVICES', 1, '"The wind whispered through the trees" uses what literary device?', 0, 'Giving wind the human ability to "whisper" is personification.', 'Personification gives human qualities to non-human things.'),
    ('27000000-0000-0000-0000-000000000032', 'G6-ENG-LITDEVICE-01', 'LITERARY_DEVICES', 2, '"Peter Piper picked a peck of pickled peppers" is an example of what?', 0, 'Repeating the same beginning sound is alliteration.', 'Listen for the repeated sound at the start of each word.'),
    ('27000000-0000-0000-0000-000000000033', 'G6-ENG-LITDEVICE-01', 'LITERARY_DEVICES', 3, '"I''ve told you a million times" uses what literary device?', 0, 'This is an obvious exaggeration, which is hyperbole.', 'Hyperbole is an exaggeration not meant to be taken literally.'),

    ('27000000-0000-0000-0000-000000000034', 'G6-ENG-ARGUMENT-01', 'ARGUMENT_EVIDENCE', 1, 'Which is the strongest evidence for "exercise improves health"?', 1, 'A scientific study of many people is stronger evidence than opinion or feeling.', 'Strong evidence is based on research, not just a single opinion.'),
    ('27000000-0000-0000-0000-000000000035', 'G6-ENG-ARGUMENT-01', 'ARGUMENT_EVIDENCE', 2, 'What is a "claim" in an argument?', 0, 'A claim is the statement the writer is trying to prove.', 'Think about what the writer wants you to believe.'),
    ('27000000-0000-0000-0000-000000000036', 'G6-ENG-ARGUMENT-01', 'ARGUMENT_EVIDENCE', 3, 'Why is evidence important in an argument?', 1, 'Evidence supports and proves the claim being made.', 'Think about what backs up a claim and makes it convincing.'),

    ('27000000-0000-0000-0000-000000000037', 'G6-ENG-COMPLEXSENT-01', 'COMPLEX_SENTENCES', 1, 'Which sentence is complex (has an independent and a dependent clause)?', 2, '"Although it was raining, the dog barked" has a dependent clause and an independent clause.', 'Look for a sentence that starts with a word like "although" or "because".'),
    ('27000000-0000-0000-0000-000000000038', 'G6-ENG-COMPLEXSENT-01', 'COMPLEX_SENTENCES', 2, 'Which word often begins a dependent clause?', 1, '"Although" often begins a dependent clause.', 'Think of words like "although," "because," and "since".'),
    ('27000000-0000-0000-0000-000000000039', 'G6-ENG-COMPLEXSENT-01', 'COMPLEX_SENTENCES', 3, 'Which sentence is a simple sentence?', 0, '"She sings" is a complete thought with no extra clause attached.', 'A simple sentence has just one independent clause and nothing else.'),

    ('27000000-0000-0000-0000-000000000040', 'G6-ENG-VOCAB-01', 'VOCAB_G6', 1, 'What does "analyze" mean?', 1, '"Analyze" means to examine something closely.', 'Think about breaking something down to understand it better.'),
    ('27000000-0000-0000-0000-000000000041', 'G6-ENG-VOCAB-01', 'VOCAB_G6', 2, 'What does "evaluate" mean?', 0, '"Evaluate" means to judge the value or quality of something.', 'Think about deciding how good or important something is.'),
    ('27000000-0000-0000-0000-000000000042', 'G6-ENG-VOCAB-01', 'VOCAB_G6', 3, 'What does "summarize" mean?', 1, '"Summarize" means to give the main points briefly.', 'Think about shrinking something down to its key ideas.'),

    ('27000000-0000-0000-0000-000000000043', 'G6-ENG-TEXTANALYSIS-01', 'TEXT_ANALYSIS', 1, 'When analyzing a text, what should you look for?', 1, 'Text analysis focuses on the author''s choices and the effects those choices create.', 'Think about why an author made certain writing choices.'),
    ('27000000-0000-0000-0000-000000000044', 'G6-ENG-TEXTANALYSIS-01', 'TEXT_ANALYSIS', 2, 'Why might an author choose short, choppy sentences in an action scene?', 1, 'Short sentences can create a sense of speed and tension.', 'Think about how reading short sentences quickly feels.'),
    ('27000000-0000-0000-0000-000000000045', 'G6-ENG-TEXTANALYSIS-01', 'TEXT_ANALYSIS', 3, 'What is "tone" in a piece of writing?', 0, 'Tone is the author''s attitude toward the subject.', 'Think about whether the writing feels serious, playful, angry, etc.'),

    ('27000000-0000-0000-0000-000000000046', 'G6-ENG-RESEARCH-01', 'RESEARCH_SKILLS', 1, 'Which source is generally most reliable for research?', 1, 'A peer-reviewed article has been checked by experts, making it more reliable.', 'Think about which source has been checked for accuracy.'),
    ('27000000-0000-0000-0000-000000000047', 'G6-ENG-RESEARCH-01', 'RESEARCH_SKILLS', 2, 'Why is it important to cite your sources?', 1, 'Citing sources gives credit and lets others verify your information.', 'Think about honesty and letting readers check your facts.'),
    ('27000000-0000-0000-0000-000000000048', 'G6-ENG-RESEARCH-01', 'RESEARCH_SKILLS', 3, 'What should you do if two sources disagree?', 1, 'You should investigate further and compare which source is more credible.', 'Do not just pick one randomly — dig deeper.'),

    ('27000000-0000-0000-0000-000000000049', 'G6-ENG-PARAPHRASE-01', 'SUMMARIZE_PARAPHRASE', 1, 'What is "paraphrasing"?', 1, 'Paraphrasing means restating something in your own words.', 'Think about saying the same idea a different way.'),
    ('27000000-0000-0000-0000-000000000050', 'G6-ENG-PARAPHRASE-01', 'SUMMARIZE_PARAPHRASE', 2, 'Why is paraphrasing useful?', 0, 'Paraphrasing shows that you understand the material.', 'Think about what putting something in your own words proves.'),
    ('27000000-0000-0000-0000-000000000051', 'G6-ENG-PARAPHRASE-01', 'SUMMARIZE_PARAPHRASE', 3, 'Which is an example of paraphrasing "The cat sat on the mat"?', 1, '"A feline rested on the rug" restates the same idea in different words.', 'Look for the choice that means the same thing but uses different words.');

INSERT INTO exercise_choices (exercise_id, choice_index, choice_text) VALUES
    ('27000000-0000-0000-0000-000000000001', 0, '1:2'), ('27000000-0000-0000-0000-000000000001', 1, '2:1'), ('27000000-0000-0000-0000-000000000001', 2, '6:3'),
    ('27000000-0000-0000-0000-000000000002', 0, '40'), ('27000000-0000-0000-0000-000000000002', 1, '60'), ('27000000-0000-0000-0000-000000000002', 2, '80'),
    ('27000000-0000-0000-0000-000000000003', 0, '4'), ('27000000-0000-0000-0000-000000000003', 1, '6'), ('27000000-0000-0000-0000-000000000003', 2, '8'),

    ('27000000-0000-0000-0000-000000000004', 0, '5'), ('27000000-0000-0000-0000-000000000004', 1, '10'), ('27000000-0000-0000-0000-000000000004', 2, '15'),
    ('27000000-0000-0000-0000-000000000005', 0, '50'), ('27000000-0000-0000-0000-000000000005', 1, '60'), ('27000000-0000-0000-0000-000000000005', 2, '70'),
    ('27000000-0000-0000-0000-000000000006', 0, '2'), ('27000000-0000-0000-0000-000000000006', 1, '4'), ('27000000-0000-0000-0000-000000000006', 2, '6'),

    ('27000000-0000-0000-0000-000000000007', 0, '2'), ('27000000-0000-0000-0000-000000000007', 1, '-2'), ('27000000-0000-0000-0000-000000000007', 2, '8'),
    ('27000000-0000-0000-0000-000000000008', 0, '-6'), ('27000000-0000-0000-0000-000000000008', 1, '-2'), ('27000000-0000-0000-0000-000000000008', 2, '6'),
    ('27000000-0000-0000-0000-000000000009', 0, '-5'), ('27000000-0000-0000-0000-000000000009', 1, '-2'), ('27000000-0000-0000-0000-000000000009', 2, 'Equal'),

    ('27000000-0000-0000-0000-000000000010', 0, '7'), ('27000000-0000-0000-0000-000000000010', 1, '8'), ('27000000-0000-0000-0000-000000000010', 2, '9'),
    ('27000000-0000-0000-0000-000000000011', 0, '6'), ('27000000-0000-0000-0000-000000000011', 1, '8'), ('27000000-0000-0000-0000-000000000011', 2, '10'),
    ('27000000-0000-0000-0000-000000000012', 0, '8'), ('27000000-0000-0000-0000-000000000012', 1, '15'), ('27000000-0000-0000-0000-000000000012', 2, '35'),

    ('27000000-0000-0000-0000-000000000013', 0, '4'), ('27000000-0000-0000-0000-000000000013', 1, '6'), ('27000000-0000-0000-0000-000000000013', 2, '14'),
    ('27000000-0000-0000-0000-000000000014', 0, '4'), ('27000000-0000-0000-0000-000000000014', 1, '10'), ('27000000-0000-0000-0000-000000000014', 2, '21'),
    ('27000000-0000-0000-0000-000000000015', 0, '4'), ('27000000-0000-0000-0000-000000000015', 1, '6'), ('27000000-0000-0000-0000-000000000015', 2, '24'),

    ('27000000-0000-0000-0000-000000000016', 0, '3'), ('27000000-0000-0000-0000-000000000016', 1, '4'), ('27000000-0000-0000-0000-000000000016', 2, '12'),
    ('27000000-0000-0000-0000-000000000017', 0, '3'), ('27000000-0000-0000-0000-000000000017', 1, '5'), ('27000000-0000-0000-0000-000000000017', 2, '7'),
    ('27000000-0000-0000-0000-000000000018', 0, '2'), ('27000000-0000-0000-0000-000000000018', 1, '3'), ('27000000-0000-0000-0000-000000000018', 2, '4'),

    ('27000000-0000-0000-0000-000000000019', 0, '12'), ('27000000-0000-0000-0000-000000000019', 1, '16'), ('27000000-0000-0000-0000-000000000019', 2, '20'),
    ('27000000-0000-0000-0000-000000000020', 0, '10'), ('27000000-0000-0000-0000-000000000020', 1, '12'), ('27000000-0000-0000-0000-000000000020', 2, '24'),
    ('27000000-0000-0000-0000-000000000021', 0, '10'), ('27000000-0000-0000-0000-000000000021', 1, '16'), ('27000000-0000-0000-0000-000000000021', 2, '22'),

    ('27000000-0000-0000-0000-000000000022', 0, '3'), ('27000000-0000-0000-0000-000000000022', 1, '4'), ('27000000-0000-0000-0000-000000000022', 2, '5'),
    ('27000000-0000-0000-0000-000000000023', 0, 'Quadrant I'), ('27000000-0000-0000-0000-000000000023', 1, 'Quadrant II'), ('27000000-0000-0000-0000-000000000023', 2, 'Quadrant III'),
    ('27000000-0000-0000-0000-000000000024', 0, '3'), ('27000000-0000-0000-0000-000000000024', 1, '4'), ('27000000-0000-0000-0000-000000000024', 2, '5'),

    ('27000000-0000-0000-0000-000000000025', 0, '2:3'), ('27000000-0000-0000-0000-000000000025', 1, '3:2'), ('27000000-0000-0000-0000-000000000025', 2, '12:18'),
    ('27000000-0000-0000-0000-000000000026', 0, '18'), ('27000000-0000-0000-0000-000000000026', 1, '30'), ('27000000-0000-0000-0000-000000000026', 2, '42'),
    ('27000000-0000-0000-0000-000000000027', 0, '20'), ('27000000-0000-0000-0000-000000000027', 1, '40'), ('27000000-0000-0000-0000-000000000027', 2, '80'),

    ('27000000-0000-0000-0000-000000000028', 0, 'They agreed quickly'), ('27000000-0000-0000-0000-000000000028', 1, 'They could not agree and delayed the vote'), ('27000000-0000-0000-0000-000000000028', 2, 'They canceled the vote entirely'),
    ('27000000-0000-0000-0000-000000000029', 0, 'She was impatient'), ('27000000-0000-0000-0000-000000000029', 1, 'She valued accuracy and preparation'), ('27000000-0000-0000-0000-000000000029', 2, 'She disliked research'),
    ('27000000-0000-0000-0000-000000000030', 0, 'It worked as planned'), ('27000000-0000-0000-0000-000000000030', 1, 'It failed to achieve its goal'), ('27000000-0000-0000-0000-000000000030', 2, 'It had no effect at all'),

    ('27000000-0000-0000-0000-000000000031', 0, 'Personification'), ('27000000-0000-0000-0000-000000000031', 1, 'Alliteration'), ('27000000-0000-0000-0000-000000000031', 2, 'Hyperbole'),
    ('27000000-0000-0000-0000-000000000032', 0, 'Alliteration'), ('27000000-0000-0000-0000-000000000032', 1, 'Metaphor'), ('27000000-0000-0000-0000-000000000032', 2, 'Irony'),
    ('27000000-0000-0000-0000-000000000033', 0, 'Hyperbole'), ('27000000-0000-0000-0000-000000000033', 1, 'Simile'), ('27000000-0000-0000-0000-000000000033', 2, 'Personification'),

    ('27000000-0000-0000-0000-000000000034', 0, 'My friend said so'), ('27000000-0000-0000-0000-000000000034', 1, 'A scientific study of 1,000 people'), ('27000000-0000-0000-0000-000000000034', 2, 'It sounds true'),
    ('27000000-0000-0000-0000-000000000035', 0, 'A statement the writer is trying to prove'), ('27000000-0000-0000-0000-000000000035', 1, 'A random fact'), ('27000000-0000-0000-0000-000000000035', 2, 'A question'),
    ('27000000-0000-0000-0000-000000000036', 0, 'It makes the writing longer'), ('27000000-0000-0000-0000-000000000036', 1, 'It supports and proves the claim'), ('27000000-0000-0000-0000-000000000036', 2, 'It is required by law'),

    ('27000000-0000-0000-0000-000000000037', 0, 'The dog barked.'), ('27000000-0000-0000-0000-000000000037', 1, 'The dog barked, and the cat ran.'), ('27000000-0000-0000-0000-000000000037', 2, 'Although it was raining, the dog barked.'),
    ('27000000-0000-0000-0000-000000000038', 0, 'And'), ('27000000-0000-0000-0000-000000000038', 1, 'Although'), ('27000000-0000-0000-0000-000000000038', 2, 'The'),
    ('27000000-0000-0000-0000-000000000039', 0, 'She sings.'), ('27000000-0000-0000-0000-000000000039', 1, 'She sings because she is happy.'), ('27000000-0000-0000-0000-000000000039', 2, 'Because she is happy, she sings.'),

    ('27000000-0000-0000-0000-000000000040', 0, 'To ignore something'), ('27000000-0000-0000-0000-000000000040', 1, 'To examine something closely'), ('27000000-0000-0000-0000-000000000040', 2, 'To forget something'),
    ('27000000-0000-0000-0000-000000000041', 0, 'To judge the value or quality of something'), ('27000000-0000-0000-0000-000000000041', 1, 'To copy something'), ('27000000-0000-0000-0000-000000000041', 2, 'To hide something'),
    ('27000000-0000-0000-0000-000000000042', 0, 'To make something longer'), ('27000000-0000-0000-0000-000000000042', 1, 'To give the main points briefly'), ('27000000-0000-0000-0000-000000000042', 2, 'To translate something'),

    ('27000000-0000-0000-0000-000000000043', 0, 'Only the length'), ('27000000-0000-0000-0000-000000000043', 1, 'The author''s choices and their effects'), ('27000000-0000-0000-0000-000000000043', 2, 'The font used'),
    ('27000000-0000-0000-0000-000000000044', 0, 'To slow the pace down'), ('27000000-0000-0000-0000-000000000044', 1, 'To create a sense of speed and tension'), ('27000000-0000-0000-0000-000000000044', 2, 'By accident'),
    ('27000000-0000-0000-0000-000000000045', 0, 'The author''s attitude toward the subject'), ('27000000-0000-0000-0000-000000000045', 1, 'The number of pages'), ('27000000-0000-0000-0000-000000000045', 2, 'The title'),

    ('27000000-0000-0000-0000-000000000046', 0, 'A random blog post'), ('27000000-0000-0000-0000-000000000046', 1, 'A peer-reviewed article'), ('27000000-0000-0000-0000-000000000046', 2, 'An anonymous social media post'),
    ('27000000-0000-0000-0000-000000000047', 0, 'To make your paper longer'), ('27000000-0000-0000-0000-000000000047', 1, 'To give credit and let others verify your information'), ('27000000-0000-0000-0000-000000000047', 2, 'It is not important'),
    ('27000000-0000-0000-0000-000000000048', 0, 'Ignore both'), ('27000000-0000-0000-0000-000000000048', 1, 'Investigate further and compare credibility'), ('27000000-0000-0000-0000-000000000048', 2, 'Pick randomly'),

    ('27000000-0000-0000-0000-000000000049', 0, 'Copying text exactly'), ('27000000-0000-0000-0000-000000000049', 1, 'Restating something in your own words'), ('27000000-0000-0000-0000-000000000049', 2, 'Deleting information'),
    ('27000000-0000-0000-0000-000000000050', 0, 'It shows you understand the material'), ('27000000-0000-0000-0000-000000000050', 1, 'It lets you avoid reading'), ('27000000-0000-0000-0000-000000000050', 2, 'It is required for all writing'),
    ('27000000-0000-0000-0000-000000000051', 0, 'The cat sat on the mat.'), ('27000000-0000-0000-0000-000000000051', 1, 'A feline rested on the rug.'), ('27000000-0000-0000-0000-000000000051', 2, 'Cats are animals.');
