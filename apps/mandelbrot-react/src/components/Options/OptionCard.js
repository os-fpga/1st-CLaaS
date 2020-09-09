import React from 'react'
import Card from '@material-ui/core/Card'
import { makeStyles } from '@material-ui/core/styles'

const useStyles = makeStyles({
	root: {
		minWidth: 275,
	},
})

const OptionCard = ({ children }) => {
	const classes = useStyles()

	return (
		<Card className={classes.root} variant='outlined'>
			{children}
		</Card>
	)
}

export default OptionCard
