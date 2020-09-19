import React from 'react'
import store from '../store'
import OptionCard from './OptionCard'

const textures = [
	{ label: 'Smooth', value: 0, checked: 0 },
	{ label: 'String lights', value: 1 },
	{ label: 'Fanciful', value: 2 },
	{ label: 'Shadow', value: 4 },
	{ label: 'Rounded edges', value: 8 },
]

const Texture = () => {
	const { renderer, texture, darken, toggleDarken, setTexture } = store()

	const handleClick = e => {
		if (e.target.checked) {
			setTexture(texture + parseInt(e.target.value))
		} else {
			setTexture(texture - parseInt(e.target.value))
		}
	}

	console.log(texture, darken)

	return (
		<OptionCard>
			<div className='title'>Renderer</div>

			<label>
				<input type='checkbox' checked={darken} onChange={toggleDarken} />{' '}
				Darken
			</label>

			{renderer === 'cpp' && (
				<form>
					{textures.map(({ label, value }, idx) => (
						<div key={idx}>
							<label>
								<input
									type='checkbox'
									id={label}
									value={value}
									name={label}
									onClick={handleClick}
								/>{' '}
								{label}
							</label>
						</div>
					))}
				</form>
			)}
		</OptionCard>
	)
}

export default Texture
