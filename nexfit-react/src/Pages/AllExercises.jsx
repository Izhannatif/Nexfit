import React, { useContext, useEffect, useState } from 'react'
import AuthContext from '../Context/AuthContext'
import { useNavigate, Link } from 'react-router-dom'
import axios from 'axios'
import { FaPlus } from "react-icons/fa6";
import { Button } from '@material-tailwind/react';
import Sidebar from '../Components/Sidebar'
const AllExercises = () => {
    let { user } = useContext(AuthContext)

    const [userData, setUserData] = useState([])
    const [gymExercises, setGymExercises] = useState([])

    const navigate = useNavigate()

    useEffect(() => {
        console.log(user);
        getUserData(user.user_id);
    }, [])

    const getUserData = async (id) => {
        let response1 = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response1.data)
        setUserData(response1.data)
        let response2 = await axios.get(`http://192.168.1.13:8001/api/exercises/`)
        console.log(response2.data)
        setGymExercises(response2.data)
    }

    return (
        <Sidebar pageName="Exercises">
            <div className='grid grid-cols-3 gap-10'>
                {
                    gymExercises.map((exercise,i)=>(
                        <div className='h-auto p-5 bg-main rounded-xl  text-gray-300 flex'>
                            <div className="w-3/12">
                                <img src={`http://192.168.1.13:8001/api${exercise.image}`} className='float-right w-full object-contain rounded-xl' style={{objectFit:'contain'}} alt="" />
                            </div>
                            <div className="w-9/12 pl-8">
                                {/* <p className='font-bold text-lg pb-5'>{i+1}</p> */}
                                <p className='text-xl font-extrabold uppercase'>{exercise.name}</p >
                                <p className='text-md font-semibold'>{exercise.exercise_type}</p>
                            </div>
                        </div>
                    ))
                }
            </div>
        </Sidebar>)
}

export default AllExercises