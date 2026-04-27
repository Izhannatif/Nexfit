import React from 'react'
import { useContext, useEffect, useState } from 'react'
import AuthContext from '../Context/AuthContext'
import { useNavigate, Link } from 'react-router-dom'
import axios from 'axios'
import logo from '../assets/nexfit-logo.png'
import { FaUser } from "react-icons/fa6";
import { RxDashboard } from "react-icons/rx";
import { CgGym } from "react-icons/cg";
import { GiMuscleUp } from "react-icons/gi";
import { MdSportsGymnastics } from "react-icons/md";
import { TbBusinessplan } from "react-icons/tb";
import { FaCoins } from "react-icons/fa";
import { CiLogout } from "react-icons/ci";


const Sidebar = ({ children, pageName }) => {
    let { user, logoutUser } = useContext(AuthContext)
    const [userData, setUserData] = useState([])
    const navigate = useNavigate();
    useEffect(() => {
        console.log(user);
        getUserData(user.user_id);
    }, [])

    const getUserData = async (id) => {
        let response = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response.data)
        setUserData(response.data)
    }
    const logout = () => {
        const response = logoutUser()
        if (response === 'success') {
            navigate('/login')
        }
    };


    return (
        <>
            <button data-drawer-target="default-sidebar" data-drawer-toggle="default-sidebar" aria-controls="default-sidebar" type="button" class="inline-flex items-center p-2 mt-2 ms-3 text-sm text-gray-500 rounded-lg sm:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:focus:ring-gray-600">
                <span class="sr-only">Open sidebar</span>
                <svg class="w-6 h-6" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                    <path clip-rule="evenodd" fill-rule="evenodd" d="M2 4.75A.75.75 0 012.75 4h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 4.75zm0 10.5a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5a.75.75 0 01-.75-.75zM2 10a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 10z"></path>
                </svg>
            </button>
            <div className="main">
            <aside id="default-sidebar" class="z-40 h-screen transition-transform -translate-x-full sm:translate-x-0 border-r border-r-black" aria-label="Sidebar">
                <div class="h-full px-3 overflow-y-auto shadow-lg dark:bg-gray-800 flex flex-col justify-between list-none fixed w-full">
                    <div>
                    <div className="p-10">
                        <img className='w-full' src={logo} alt="" srcset="" />
                    </div>
                    <ul class="space-y-2 font-medium">

                        <Link to={'/'}>
                        <li>
                            <a href="" class={`nav-main ${pageName == 'Dashboard' && 'active-link'}`}>
                                <RxDashboard />
                                <span class="ms-3">Dashboard</span>
                            </a>
                        </li>
                        </Link>
                        <Link to={'/all-users'}><li>
                            <a href="" class={`nav-main ${pageName == 'Members' && 'active-link'}`}>
                                <FaUser />
                                <span class="flex-1 ms-3 whitespace-nowrap">Members</span>

                            </a>
                        </li></Link>
                        <Link to={'/all-trainers'}><li>
                            <a href="" class={`nav-main ${(pageName == 'Trainers' || pageName == 'New Trainer') && 'active-link'}`}>
                               <GiMuscleUp />
                                <span class="flex-1 ms-3 whitespace-nowrap">Trainers</span>

                            </a>
                        </li></Link>
                        <Link to={'/all-equipments'}><li>
                            <a href="" class={`nav-main ${pageName == 'Equipments' || pageName == 'Add Equipment' && 'active-link'}`}>
                                <CgGym />
                                <span class="flex-1 ms-3 whitespace-nowrap">Equipments</span>
                            </a>
                        </li></Link>
                        <Link to={'/all-exercises'}><li>
                            <a href="" class={`nav-main ${pageName == 'Exercises' && 'active-link'}`}>
                                <MdSportsGymnastics />
                                <span class="flex-1 ms-3 whitespace-nowrap">Exercises</span>
                            </a>
                        </li></Link>

                        <Link to={'/add-token-plan'}><li >
                            <a href="" class={`nav-main ${pageName == 'Token Plans' && 'active-link'}`}>
                                <FaCoins />
                                <span class="flex-1 ms-3 whitespace-nowrap">Token Plans</span>

                            </a>
                        </li></Link>
                        <Link to={'/plan-purchase'} ><li>
                            <a href="" class={`nav-main ${pageName == 'Purchases' && 'active-link'}`}>
                                <TbBusinessplan />
                                <span class="flex-1 ms-3 whitespace-nowrap">Purchases</span>
                            </a>
                        </li></Link>
                    </ul>
                </div>
                    <ul class="space-y-2 font-medium bg-red-900 mb-8 rounded-lg text-white">
                        <li onClick={logout} className=' rounded-lg font-bold text-white'>
                            <a href="" class="nav-main">
                                <CiLogout />
                                <span class="flex-1 ms-3 whitespace-nowrap text-white">Logout</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </aside>
            <div className="main-body">
                <nav className='shadow-sm p-5 px-8 z-50 flex justify-between items-center bg-main'>
                    <div className="text-xl font-bold text-white">
                        {pageName}
                    </div>
                    <div>
                        <span className="text-md font-bold text-white capitalize">{userData.gym_name}</span>
                    </div>
                </nav>
                <div className="p-8">
                    {children}
                </div>
            </div>

            </div>
        </>
    )
}

export default Sidebar