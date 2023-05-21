array_shapes = {}

-- top left corner
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 1
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'###',
'#++',
'#+?')

-- top wall
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 2
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'###',
'+++',
'???')

-- top wall 2
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 2
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'###',
'+++',
'+??')

-- top wall 3
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 2
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'###',
'+++',
'??+')

-- top right corner
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 3
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'###',
'++#',
'?+#')

-- left wall
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 4
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#+?',
'#+?',
'#+?')

-- left wall 2
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 4
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#++',
'#+?',
'#+?')

-- left wall 3
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 4
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#+?',
'#+?',
'#++')

-- left wall 5
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 4
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'###',
'#+?',
'++?')

-- left wall 6
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 4
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#+?',
'#+?',
'++?')


-- right wall
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 6
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'?+#',
'?+#',
'?+#')

-- right wall 2
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 6
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'++#',
'?+#',
'?+#')

-- right wall 3
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 6
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'?+#',
'?+#',
'++#')


-- bottom left corner
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 7
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#+?',
'#++',
'###')

-- bottom wall
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 8
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'???',
'+++',
'###')

-- bottom wall 2
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 8
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'+??',
'+++',
'###')

-- bottom wall 3
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 8
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'??+',
'+++',
'###')

-- bottom right corner
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 9
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'?+#',
'++#',
'###')

-- bottom door right
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 10
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'???',
'?++',
'###')

-- bottom door left
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 11
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'???',
'++?',
'###')

-- top door right
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 13
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'###',
'?++',
'???')

-- top door left
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 14
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'###',
'++?',
'???')

-- top door left 3
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 14
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#++',
'++?',
'???')

-- top door left 4
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 14
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#+?',
'++?',
'???')

-- right door bottom
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 16
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'??#',
'?+#',
'?+#')

-- right door top

array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 19
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'?+#',
'?+#',
'??#')

-- left door bottom
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 17
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#??',
'#+?',
'#+?')

-- left door top
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 20
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#+?',
'#+?',
'#??')

-- left door top
array_shapes[#array_shapes + 1] = new_str_array()
array_shapes[#array_shapes].val = 20
array_shapes[#array_shapes]:format()
array_shapes[#array_shapes]:set_shape(
'#++',
'#+?',
'#??')