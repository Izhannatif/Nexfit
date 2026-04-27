import { createContext, useState, useEffect } from 'react'
import axios from 'axios';
import { data } from 'autoprefixer';
import { jwtDecode } from 'jwt-decode'
import { useNavigate } from 'react-router-dom'
import { ToastContainer } from 'react-toastify';

const AuthContext = createContext()

export default AuthContext;

export const AuthProvider = ({ children }) => {

    // localStorage.getItem('authtokens') ? JSON.parse(localStorage.getItem('authtokens')) : null

    let [authTokens, setAuthTokens] = useState(() => localStorage.getItem('authtokens') ? JSON.parse(localStorage.getItem('authtokens')) : null)
    let [user, setUser] = useState(() => localStorage.getItem('authtokens') ? jwtDecode(localStorage.getItem('authtokens')) : null)

    // let loginUser = async (e) => {
    //     // e.preventDefault()
    //     console.log('Form Submitted.')
    //     let response = await axios.post('http://192.168.1.13:8001/api/token/', { 'username': e.target.username.value, 'password': e.target.password.value })
    //     console.log(response.data)
    //     if (response.status === 200) {
    //         setAuthTokens(response.data)
    //         setUser(jwtDecode(response.data.access))
    //         localStorage.setItem('authtokens', JSON.stringify(response.data))
    //         return true
    //     }
    //     else if (response.status === 401) {
    //         alert('Incorrect Username or Password');
    //     }

    // }
    let loginUser = async (e) => {
        // e.preventDefault()
        console.log('Form Submitted.')
        try {
            let response = await axios.post('http://192.168.1.13:8001/api/token/', {
                'username': e.target.username.value,
                'password': e.target.password.value
            });
            console.log(response.data);
            if (response.status === 200) {
                setAuthTokens(response.data);
                setUser(jwtDecode(response.data.access));
                localStorage.setItem('authtokens', JSON.stringify(response.data));
                return true;
            }
        } catch (error) {
            if (error.response && error.response.status === 401) {
                alert('Incorrect Username or Password');
            } else if (error.response && error.response.status === 400) {
                alert('Bad Request: Please check your input');
            } else {
                alert('An unexpected error occurred. Please try again later.');
            }
            console.error('Error logging in:', error);
            return false;
        }
    }
    let registerUser = async (e, trainer) => {
        // e.preventDefault()
        console.log('Form Submitted.')
        let response = await axios.post('http://192.168.1.13:8001/api/register-user/',
            { 'username': e.target.username.value, 'email': e.target.email.value, 'first_name': e.target.first_name.value, 'last_name': e.target.last_name.value, 'password': e.target.password.value, 'gym_id': e.target.gym_id.value, 'contact': e.target.contact.value, 'trainer': trainer })
        console.log('gym = ', e.target.gym_id.value)
        console.log("trainer ID below")
        console.log(trainer)
        console.log(response.data)

        if (response.status === 200) {
            alert('User Created Successfully!')
            return 'success'
        }
        else {
            alert('Something went wrong')
        }
    }
    let registerTrainer = async (e) => {
        // e.preventDefault()
        console.log('Form Submitted.')
        console.log()
        let response = await axios.post('http://192.168.1.13:8001/api/register-trainer/', { 'username': e.target.username.value, 'email': e.target.email.value, 'first_name': e.target.first_name.value, 'last_name': e.target.last_name.value, 'password': e.target.password.value, 'gym_id': e.target.gym_id.value, 'contact': e.target.contact.value, 'certification': e.target.certification.value, 'monthly_charges': e.target.monthly_charges.value })
        console.log('gym = ', e.target.gym_id.value)
        console.log(response.data)

        if (response.status === 200) {
            alert('Trainer Created Successfully!')
            return 'success'
        }
        else {
            alert('Something went wrong')
        }
    }
    let logoutUser = () => {
        setAuthTokens(null)
        setUser(null)
        localStorage.removeItem('authtokens');
        return 'success';
    }

    let updateToken = async () => {
        let response = await axios.post('http://192.168.1.13:8001/api/token/', { 'refresh': authTokens.refresh })
        console.log(response.data)

    }

    let contextData = {
        user: user,
        registerUser: registerUser,
        registerTrainer: registerTrainer,
        loginUser: loginUser,
        logoutUser: logoutUser,
    }


    return (
        <AuthContext.Provider value={contextData}>
            <ToastContainer />
            {children}
            {/* </ToastContainer> */}
        </AuthContext.Provider>
    )
}
