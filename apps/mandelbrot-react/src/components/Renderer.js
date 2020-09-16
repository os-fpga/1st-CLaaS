import React from 'react'
import OptionCard from './OptionCard'
import store from '../store'

export const renderers = [
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
	const { renderer, setRenderer } = store()

	return (
		<OptionCard>
			<div className='title'>Renderer</div>

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
