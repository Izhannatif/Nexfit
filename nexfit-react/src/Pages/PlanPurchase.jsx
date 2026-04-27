import React, { useContext, useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom';
import AuthContext from '../Context/AuthContext'
import axios from 'axios'
import Sidebar from '../Components/Sidebar'
import { FaCheck } from 'react-icons/fa6';
import { ToastContainer, toast, Bounce } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';


const PlanPurchase = () => {
    const [userData, setUserData] = useState([])
    const [gymID, setGymID] = useState();
    let { user } = useContext(AuthContext)
    const [username, setUsername] = useState('')
    const [selectedUser, setSelectedUser] = useState([])
    const [tokenPlans, setTokenPlans] = useState([])
    const [selectedPlan, setSelectedPlan] = useState([])
    useEffect(() => {
        getUserData(user.user_id);
    }, [])

    const navigate = useNavigate();
    const getUserData = async (id) => {
        let response1 = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response1.data)
        let response2 = await axios.get(`http://192.168.1.13:8001/api/${response1.data.gym}/get-token-plans`)
        console.log(response2.data)
        setTokenPlans(response2.data)
        setGymID(response1.data.gym)
    }

    useEffect(() => {
        if (username != '') {
            searchUser(username)
        }
        if (username == '') {
            setUserData([])
        }
    }, [username])

    const searchUser = async (username) => {
        let response = await axios.get(`http://192.168.1.13:8001/api/get-user/${gymID}/${username}/`)
        if (response) {
            if (response.data != '') {
                setUserData(response.data)
                console.log(response.data)
            }
        }
    }
    const startDate = new Date().toISOString().split('T')[0];
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + 1);
    const formattedEndDate = endDate.toISOString().split('T')[0];


    let addPlanPurchase = async (e) => {
        try {
            let response = await axios.post('http://192.168.1.13:8001/api/add-plan-purchase/', {
                'gym_user_id': selectedUser.id,
                'number_of_tokens': selectedPlan.number_of_tokens,
                'plan_price': selectedPlan.plan_price,
                'gym_id': selectedUser.gym_id,
                'token_plan_id': selectedPlan.id,
                'name': selectedPlan.name,
                'start_date': startDate,
                'end_date': formattedEndDate
            });
            if (response.status === 200) {
                return 'success';
            }
        } catch (error) {
            console.error(error);
            // alert('An error occurred. Please try again.');
            toast.error('Please Select a Token Plan', {
                position: "top-center",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "colored",
                transition: Bounce,
            });
        }
        return null;
    }

    const handleForm = async (e) => {
        e.preventDefault();
        const response = await addPlanPurchase(e);
        if (response === 'success') {
            toast.success('Purchase Completed', {
                position: "top-right",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "colored",
                transition: Bounce,
            });
            navigate('/');
        } else {
            toast.error('Select the User to add token plan', {
                position: "top-center",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "colored",
                transition: Bounce,
            });
        }

    }
    return (
        <Sidebar pageName="Purchases">
            <form onSubmit={handleForm} className='w-full'>
                <div className=''>
                    <center><input type="text" name="username" id="username" placeholder='Search User by Username' onChange={(e) => {
                        setUsername(e.target.value)
                        console.log(e.target.value)
                    }} className='w-9/12 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] 
                    border-stone-300 rounded-md text-stone-950' />
                    </center>
                </div>

                {
                    userData && userData.map((user, i) => (
                        <div key={i}
                            className='p-3 m-2 bg-main rounded-lg text-sm' onClick={() => {
                                setSelectedUser(user)
                                setUserData([])
                                console.log(user)
                            }}>

                            <p>Name : {user.first_name} {user.last_name}</p>
                            <p>Username : {user.username}</p>
                            <p>Email: {user.email}</p>
                            <p>Tokens: {user.number_of_tokens}</p>
                        </div>
                    ))
                }

                {


                    selectedUser.first_name ?
                        <div className='w-1/5 p-5 m-5 rounded-lg bg-main'>

                            <FaCheck className='float-right text-lime-700' />
                            <p className='font-medium text-lg pb-2'>Selected User</p>

                            <p>Name : {selectedUser.first_name} {user.last_name}</p>
                            <p>Username : {selectedUser.username}</p>
                            <p>Email: {selectedUser.email}</p>
                            <p>Tokens: {selectedUser.number_of_tokens}</p>
                        </div> : null
                }
                <div className='flex flex-col'>
                    <p className='text-2xl font-bold uppercase p-5 m-5 text-center'>PLANS AVAILABLE</p>
                    <div className='grid grid-cols-3 gap-10'>
                        {
                            tokenPlans.map((plan, i) => (
                                <div key={i} className={`p-10 text-center rounded-xl ${selectedPlan == plan ? 'bg-white text-black' : 'bg-main text-white'}`} onClick={() => {
                                    setSelectedPlan(plan)
                                    console.log(plan)
                                }} >
                                    <p className='text-lg font-bold'>{plan.name}</p>
                                    <br />
                                    <p>Consists of <b>{plan.number_of_tokens}</b> Tokens</p>
                                    <p className=''>For {plan.duration_of_months} Month/s</p>
                                    <p className='text-xl font-medium'>PKR {plan.plan_price} /- </p>
                                    <p>{plan.description}</p>

                                    <p></p>
                                </div>
                            ))
                        }
                    </div>

                    <center><button className='w-10/12 border-none px-10 py-3 my-16 bg-lime-400 rounded-lg font-bold text-black' onClick={() => { }}>Purchase Plan</button></center>

                </div>
            </form>
        </Sidebar>
    )
}

export default PlanPurchase