import React from 'react'
import OptionCard from './OptionCard'
import store from '../store'

export const themes = [
	{
		value: 0,
		label: 'Customize',
	},
	{
		value: 1,
		label: 'Christmas',
	},
]

const Renderer = () => {
	const { theme, setTheme } = store()

	return (
		<OptionCard>
			<div className='title'>Theme</div>

			<form>
				{themes.map(({ label, value }, idx) => (
					<div key={idx}>
						<label>
							<input
								type='radio'
								checked={theme === value}
								value={value}
								name='theme'
								onChange={setTheme}
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
