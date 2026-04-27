import React, { useContext, useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom';
import AuthContext from '../Context/AuthContext'
import axios from 'axios'
import Sidebar from '../Components/Sidebar'

const AddTokenPlan = () => {
    const [userData, setUserData] = useState([])
    const [gymID, setGymID] = useState();
    let { user } = useContext(AuthContext)

    useEffect(() => {
        getUserData(user.user_id)
    }, [])

    const navigate = useNavigate();

    const getUserData = async (id) => {
        let response = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response.data)
        setUserData(response.data)
        setGymID(response.data.gym)
    }

    let addTokenPlan = async (e) => {
        // e.preventDefault()
        console.log('Add Token Plan Form Submitted.')
        let response = await axios.post('http://192.168.1.13:8001/api/add-token-plan/',
            { 'name': e.target.name.value, 'number_of_tokens': e.target.number_of_tokens.value, 'plan_price': e.target.plan_price.value, 'duration_of_months': e.target.duration_of_months.value, 'description': e.target.description.value, 'gym_id': e.target.gym_id.value })
        console.log(response.data)

        if (response.status === 200) {
            //   alert('Equipment Added Successfully!')
            return 'success'
        }
        else {
            alert('Something went wrong')
        }
    }

    const handleForm = async (e) => {
        e.preventDefault();
        const response = await addTokenPlan(e);
        if (response === 'success') {
            navigate('/')
            alert('Token Plan Added Successfully')
        }
    };
    return (
        <Sidebar pageName="Token Plans">
            <form onSubmit={handleForm}>
                <div className='flex flex-col'>
                    <div>
                        <input required={true} type="text" name="name" id="name" placeholder='Enter Plan Name' className='w-1/4 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

                        <input required={true} type="text" name="description" id="description" placeholder='Enter Plan Description' className='w-1/4 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
                    </div>
                    <div>
                        <input required={true} type="number" name="number_of_tokens" id="number_of_tokens" placeholder='Enter Number of Tokens' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

                        <input required={true} type="number" name="duration_of_months" id="duration_of_months" placeholder='Enter Duration of Months' className='w-1/4 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
                    </div>

                    <input required={true} type="number" name="plan_price" id="plan_price" placeholder='Enter Plan Price' className='w-1/4 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

                    <input required={true} hidden={true} type="text" name="gym_id" id="gym_id" placeholder='Enter gym' className='w-1/4 py-3 px-2 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' defaultValue={gymID} value={gymID} />



                    <button className='w-1/4 border-none px-10 py-3 m-5 text-black bg-lime-400 rounded-lg font-bold' onClick={() => { }}>ADD</button>
                </div>
            </form>
        </Sidebar>
    )
}

export default AddTokenPlan