import React from 'react'
import Paper from '@material-ui/core/Paper'

const OptionCard = ({ children, title }) => {
	return (
		<div className='option-card'>
			<Paper className='card' variant='outlined'>
				<div style={{ margin: '3%' }}>{children}</div>
			</Paper>
		</div>
	)
}

export default OptionCard
