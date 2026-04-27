import React, { useContext, useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom';
import AuthContext from '../Context/AuthContext'
import axios from 'axios'
import Sidebar from '../Components/Sidebar'


const AddUser = () => {
    const [userData, setUserData] = useState([])
    const [gymID, setGymID] = useState();
    const [trainers, setTrainers] = useState([])
    const [selectedTrainer, setSelectedTrainer] = useState([])
    const [selectedTrainerid, setSelectedTrainerid] = useState('No Trainer')
    const [trainerFee, setTrainerFee] = useState('');
    let { user } = useContext(AuthContext)

    useEffect(() => {
        getUserData(user.user_id)
    }, [])
    const getUserData = async (id) => {
        let response1 = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response1.data)
        setUserData(response1.data)
        setGymID(response1.data.gym)
        getTrainers(response1.data.gym)
    }

    const getTrainers = async (id) => {
        try {
            const res = await axios.get(`http://192.168.1.13:8001/api/gym-trainers/${id}`)
            console.log(res.data)
            setTrainers(res.data)
        } catch (err) {
            console.error(err)
        }
    }

    useEffect(() => {
        if (selectedTrainer != '') {
            const temp = selectedTrainer.split('-');
            var tempId = temp[0];
            setSelectedTrainerid(parseInt(tempId))
            var tempName = temp[1];
            var tempFee = temp[2];
            if (tempName !== 'No Trainer' && tempName !== '') {
                setSelectedTrainerid(tempId);
                setTrainerFee(`Trainer Monthly Fees: ${tempFee.toLocaleString()}`)
            }
            else if (selectedTrainerid === 'No Trainer') {
                return null
            }
        }
    }, [selectedTrainer])
    const navigate = useNavigate();
    let { registerUser } = useContext(AuthContext)

    const handleRegister = async (e) => {
        e.preventDefault();
        const response = await registerUser(e, selectedTrainerid);
        if (response === 'success') {
            navigate('/')
        }
    };

    return (
        <Sidebar pageName="Add User">
            <div className=' '>
                <p className='text-3xl font-bold px-5 py-10 flex uppercase'>NEW MEMBER</p>
            </div>
            <form onSubmit={handleRegister}>
                <div className='flex flex-col flex-wrap '>

                    <div>
                        <input required={true} type="text" name="username" id="username" placeholder='Enter Username' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] 
                    border-stone-300 rounded-md text-stone-950' />

                        <input required={true} type="email" name="email" id="emaik" placeholder='Enter Email' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
                    </div>
                    <div>
                        <input required={true} type="text" name="first_name" id="first_name" placeholder='Enter First name' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

                        <input required={true} type="text" name="last_name" id="last_name" placeholder='Enter Last Name' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
                    </div>
                    <div>
                        <input required={true} type="number" name="contact" id="contact" placeholder='Enter Contact Number' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

                        <input required={true} type="password" name="password" id="password" placeholder='Enter Password' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
                    </div>
                    <div>
                        <select name="trainer" id="trainer" onChange={(e) => {
                            setSelectedTrainer(e.target.value)
                        }} className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' >
                            <option value="No Trainer">No Trainer</option>
                            {
                                trainers.map((trainer, i) => (
                                    <option key={i} value={trainer.user + "-" + trainer.first_name + " " + trainer.last_name + "-" + trainer.monthly_charges}>{trainer.first_name} {trainer.last_name}</option>
                                ))
                            }
                        </select>
                        <input required={true} hidden={true} type="text" name="gym_id" id="gym_id" placeholder='Enter gym' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' defaultValue={gymID} value={gymID} />
                        <button className='border-none px-36 py-3 m-5 text-black bg-lime-400 rounded-lg font-bold' onClick={() => { }}>Create</button>
                    </div>

                    <div className='p-5'>
                        {trainerFee ?? `${trainerFee}` + ' PKR'}
                    </div>

                </div>
            </form>
        </Sidebar>
    )
}

export default AddUser