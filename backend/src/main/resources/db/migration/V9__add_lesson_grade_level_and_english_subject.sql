-- Extends the catalog beyond Grade 1 Math: lessons now carry a grade level so a child's lesson
-- list can be filtered to their own grade (previously every lesson was shown to every child
-- regardless of grade, flagged as a real gap before adding more grades — see docs/PHASE_6_PLAN.md
-- "Additional subjects and grades"). The five existing Grade 1 lessons default to GRADE_1, which
-- is already correct for every row that exists today.
ALTER TABLE lessons ADD COLUMN grade_level VARCHAR(20) NOT NULL DEFAULT 'GRADE_1';

-- English/Reading joins Math as the second subject.
INSERT INTO subjects (code, name) VALUES ('ENGLISH', 'English and Reading');
