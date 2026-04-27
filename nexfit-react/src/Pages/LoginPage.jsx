import React, { useContext } from 'react'
import '../index.css'
import AuthContext from '../Context/AuthContext'
import { useNavigate } from 'react-router-dom'
import logo from '../assets/nexfit-logo.png'

const LoginPage = () => {
    let { loginUser } = useContext(AuthContext)

    const navigate = useNavigate()
    const handleLogin = async (e) => {
        e.preventDefault();
        const response = await loginUser(e);
        console.log(response)
        response ? navigate('/') : alert('Invalid username or password');
    };
    return (
        <section className='h-screen w-screen bg-main flex flex-row  items-center'>
            <div className='h-screen w-[50vw] text-center flex items-center px-28 '>
                <div className="p-10">
                    <img className='w-full' src={logo} alt="" srcSet="" />
                </div>
            </div>
            <div className='h-[80vh] w-[45vw] bg-main flex flex-col items-center pt-10 shadow-[0px_0px_10px_black] rounded-3xl'>
                <h1 className='text-center text-4xl font-extrabold text-lime-500 py-10 '>Gym <br /> Admin Panel</h1>
                <form method='POST' onSubmit={handleLogin} className='ml-40'>
                    <input type="text" name="username" id="username" placeholder='Enter Username' className='w-4/6 py-3 px-2 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
                    <input type="password" name="password" id="password" placeholder='Enter Password' className='w-4/6 py-3 px-2 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
                    <button className='text-black border-none w-4/6 py-3 my-5 bg-lime-500 drop-shadow-[6px_6px_0px_black] hover:drop-shadow-none rounded-md text-stone-900 text-lg font-extrabold duration-500 '>LOGIN</button>
                </form>
            </div>
        </section>
    )
}

export default LoginPage