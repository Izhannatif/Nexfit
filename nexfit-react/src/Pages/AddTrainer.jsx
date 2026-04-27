import React, { useContext, useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom';
import AuthContext from '../Context/AuthContext'
import axios from 'axios'
import Sidebar from '../Components/Sidebar'

const AddTrainer = () => {
    const [userData, setUserData] = useState([])
    const [gymID, setGymID] = useState();
    let { user } = useContext(AuthContext)

    useEffect(() => {
        getUserData(user.user_id)
    }, [])
    const getUserData = async (id) => {
        let response = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response.data)
        setUserData(response.data)
        setGymID(response.data.gym)
    }
    const navigate = useNavigate();
    let { registerTrainer } = useContext(AuthContext)
    const handleRegister = async (e) => {
        e.preventDefault();
        const response = await registerTrainer(e);
        if (response === 'success') {
            navigate('/')
        }
    };
    return (
        <Sidebar pageName="New Trainer">
            <form className='bg-main p-8 rounded-lg' onSubmit={handleRegister}>
                <div className='grid grid-cols-3 gap-10'>
                    <input required={true} type="text" name="username" id="username" placeholder='Enter Username' className='py-3 px-2 mx-5 my-5 bg-black border 
                    border-stone-300 rounded-md text-stone-950' />

                    <input required={true} type="email" name="email" id="email" placeholder='Enter Email' className='py-3 px-2 my-5 mx-5 bg-black border border-stone-300 rounded-md text-stone-950' />
                    <input required={true} type="text" name="first_name" id="first_name" placeholder='Enter First name' className='py-3 px-2 mx-5 my-5 bg-black border border-stone-300 rounded-md text-stone-950' />

                    <input required={true} type="text" name="last_name" id="last_name" placeholder='Enter Last Name' className='py-3 px-2 my-5 mx-5 bg-black border border-stone-300 rounded-md text-stone-950' />
                    <input required={true} type="number" name="contact" id="contact" placeholder='Enter Contact Number' className='py-3 px-2 my-5 mx-5 bg-black border border-stone-300 rounded-md text-stone-950' />

                    <input required={true} type="password" name="password" id="password" placeholder='Enter Password' className='py-3 px-2 my-5 mx-5 bg-black border border-stone-300 rounded-md text-stone-950' />
                    <input required={true} type="text" name="certification" id="certification" placeholder='Enter Certification' className='py-3 px-2 mx-5 my-5 bg-black border border-stone-300 rounded-md text-stone-950' />

                    <input required={true} type="number" name="monthly_charges" id="monthly_charges" placeholder='Enter Monthly Charges' className='py-3 px-2 mx-5 my-5 bg-black border border-stone-300 rounded-md text-stone-950' />
                    <input required={true} hidden={true} type="text" name="gym_id" id="gym_id" placeholder='Enter gym' className='py-3 px-2 my-5 bg-black border border-stone-300 rounded-md text-stone-950' defaultValue={gymID} value={gymID} />

                    <button className='w-full border-none px-5 py-0 mt-5  text-black bg-lime-400 rounded-lg font-bold' onClick={() => { }}>Create</button>
                </div>
            </form>
        </Sidebar>
    )
}

export default AddTrainer