import create from 'zustand'

const useStore = create(set => ({
	height: 256,
	width: 256,
	renderer: 'cpp',
	x: 0,
	y: 0,
	brighten: 0,
	colors: 2,
	darken: true,
	edge: 0,
	eye_adjust: 0,
	eye_sep: 0,
	max_depth: 1225,
	modes: 66,
	offset_h: 0,
	offset_w: 0,
	pix_x: 0.015625,
	pix_y: 0.015625,
	test_flags: 0,
	test_vars: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	texture: 0,
	theme: 0,
	three_d: false,
	var1: 0,
	var2: 0,

	// setter functions
	setRenderer: e => set({ renderer: e.target.value }),
}))

export default useStore
