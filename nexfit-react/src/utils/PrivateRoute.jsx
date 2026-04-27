import { useEffect } from 'react'
import { Route, redirect, Navigate } from 'react-router-dom'

const PrivateRoute = ({ children, ...rest }) => {

    const authenticated = true
    const isAuthenticated = localStorage.getItem('authtokens')
    
    return (
        isAuthenticated == null ? <Navigate to='/login' replace /> : children
    )
}

export default PrivateRoute;