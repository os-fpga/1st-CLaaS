import React from 'react'
import OptionCard from './OptionCard'
import store from '../store'

const renderers = [
	{
		value: 'python',
		label: 'Python',
	},
	{
		value: 'cpp',
		label: 'C++',
	},
	{
		value: 'fpgq',
		label: 'FPGA/opt',
	},
]

const Renderer = () => {
	const { renderer, setRenderer, tiled, toggleTiled } = store()

	return (
		<OptionCard>
			<div className='title'>Renderer</div>

			<label>
				<input type='checkbox' checked={tiled} onChange={toggleTiled} /> Tiled
			</label>

			<form>
				{renderers.map(({ label, value }, idx) => (
					<div key={idx}>
						<label>
							<input
								type='radio'
								checked={value === renderer}
								value={value}
								name='renderer'
								onChange={setRenderer}
							/>{' '}
							{label}
						</label>
					</div>
				))}
			</form>
		</OptionCard>
	)
}

export default Renderer
