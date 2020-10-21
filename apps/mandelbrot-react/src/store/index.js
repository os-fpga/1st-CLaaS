import create from 'zustand'

const useStore = create(set => ({
	brighten: 0,
	colors: 2,
	darken: false,
	edge: 0,
	eye_adjust: 0,
	eye_sep: 0,
	height: 256,
	max_depth: 1225,
	modes: 66,
	offset_h: 0,
	offset_w: 0,
	pix_x: 0.015625,
	pix_y: 0.015625,
	renderer: 'cpp',
	test_flags: 0,
	test_vars: (16)[(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)],
	texture: 0,
	theme: 0,
	three_d: false,
	var1: 0,
	var2: 0,
	width: 256,
	x: 0,
	y: 0,

	// setter functions
	setRenderer: e =>
		set(store => ({
			renderer: e.target.value,
			theme: e.target.value === 'cpp' ? store.theme : 0,
		})), // set Renderer

	toggleTiled: () =>
		set(store => ({ ...store, tiled: !store.tiled, three_d: false })), // toggle Tiled

	setThreeD: e => set({ three_d: e.target.value === 'true' }), // set 3-D options

	setTheme: e => set({ theme: parseInt(e.target.value) }), // set Theme

	setColors: e => set({ colors: parseInt(e.target.value) }),

	toggleDarken: () => set(store => ({ ...store, darken: !store.darken })),

	setTexture: texture => set({ texture }),

	setSize: (width, height) => set({ width, height }),

	setXY: (x, y) => set({ x, y }),

	setPix: pix =>
		set(state => ({ pix_x: state.pix_x + pix, pix_y: state.pix_x + pix })),
}))

export default useStore
