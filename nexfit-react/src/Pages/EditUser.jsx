// import React, { useContext, useEffect, useState } from 'react';
// import { useNavigate, useParams } from 'react-router-dom';
// import AuthContext from '../Context/AuthContext';
// import axios from 'axios';

// const EditUser = () => {
//     const { id } = useParams(); // Retrieve the user ID from the URL parameters
//     const [userData, setUserData] = useState({});
//     const [trainers, setTrainers] = useState([]);
//     const [selectedTrainer, setSelectedTrainer] = useState('No Trainer');
//     const [trainerFee, setTrainerFee] = useState('');
//     const navigate = useNavigate();
//     const { user } = useContext(AuthContext);

//     useEffect(() => {
//         getUserData(user.user_id, id);
//         console.log(user.user_id);
        
//     }, [id]);


//     const getUserData = async (adminID, userID) => {
//         let response1 = await axios.get(`http://192.168.1.13:8001/api/admin/${adminID}/`)
//         let response2 = await axios.get(`http://192.168.1.13:8001/api/get-user/${userID}/`)
//         console.log(response2.data.trainer)        
//         console.log(response2.data)
//         setUserData(response2.data)
//         getTrainers(response1.data.gym)
//     }

//     const getTrainers = async (id) => {
//         try {
//             const res = await axios.get(`http://192.168.1.13:8001/api/gym-trainers/${id}`)
//             console.log(res.data)
//             setTrainers(res.data)
//         } catch (err) {
//             console.error(err)
//         }
//     }


//     useEffect(() => {
//         if (selectedTrainer) {
//             const [tempId, tempName, tempFee] = selectedTrainer.split('-');
//             if (tempName !== 'No Trainer') {
//                 setTrainerFee(`Trainer Monthly Fees: ${tempFee}`);
//             } else {
//                 setTrainerFee('');
//             }
//         }
//     }, [selectedTrainer]);

//     const handleUpdate = async (e) => {
//         e.preventDefault();
//         try {
//             await axios.put(`http://192.168.1.13:8001/api/user-update/${id}/`, {
//                 ...userData,
//                 trainer: selectedTrainer.split('-')[0],
//             });
//             navigate('/'); // Redirect after successful update
//         } catch (error) {
//             console.error('Error updating user data:', error);
//         }
//     };

//     return (
//         <section className='sm:ml-64 sm:mt-16'>
//             <div>
//                 <p className='text-3xl font-bold px-5 py-10 uppercase'>Edit Member</p>
//             </div>
//             <form onSubmit={handleUpdate}>
//                 <div className='flex flex-col'>
//                     <div>
//                         <input
//                             type="text"
//                             name="username"
//                             placeholder='Username'
//                             value={userData.username || ''}
//                             onChange={(e) => setUserData({ ...userData, username: e.target.value })}
//                             className='input-field'
//                         />
//                         <input
//                             type="email"
//                             name="email"
//                             placeholder='Email'
//                             value={userData.email || ''}
//                             onChange={(e) => setUserData({ ...userData, email: e.target.value })}
//                             className='input-field'
//                         />
//                     </div>
//                     <div>
//                         <input
//                             type="text"
//                             name="first_name"
//                             placeholder='First Name'
//                             value={userData.first_name || ''}
//                             onChange={(e) => setUserData({ ...userData, first_name: e.target.value })}
//                             className='input-field'
//                         />
//                         <input
//                             type="text"
//                             name="last_name"
//                             placeholder='Last Name'
//                             value={userData.last_name || ''}
//                             onChange={(e) => setUserData({ ...userData, last_name: e.target.value })}
//                             className='input-field'
//                         />
//                     </div>
//                     <div>
//                         <input
//                             type="tel"
//                             name="contact"
//                             placeholder='Contact Number'
//                             value={userData.contact || ''}
//                             onChange={(e) => setUserData({ ...userData, contact: e.target.value })}
//                             className='input-field'
//                         />
//                     </div>
//                     <div>
//                         <select
//                             name="trainer"
//                             value={userData.trainer || selectedTrainer}
//                             onChange={(e) => setSelectedTrainer(e.target.value)}
//                             className='input-field'
//                         >
//                             <option value="No Trainer">No Trainer</option>
//                             {trainers.map((trainer, index) => (
//                                 <option key={index} value={`${trainer.id}-${trainer.first_name} ${trainer.last_name}-${trainer.monthly_charges}`}>
//                                     {trainer.first_name} {trainer.last_name}
//                                 </option>
//                             ))}
//                         </select>
//                         <input
//                             hidden
//                             type="text"
//                             name="gym_id"
//                             value={userData.gym || ''}
//                             readOnly
//                             className='input-field'
//                         />
//                         <button type="submit" className='submit-button'>Update</button>
//                     </div>
//                     <div className='fee-display'>
//                         {trainerFee}
//                     </div>
//                 </div>
//             </form>
//         </section>
//     );
// };

// export default EditUser;

// import React, { useContext, useEffect, useState } from 'react';
// import { useNavigate, useParams } from 'react-router-dom';
// import AuthContext from '../Context/AuthContext';
// import axios from 'axios';
// import Sidebar from '../Components/Sidebar'

// const EditUser = () => {
//     const { id } = useParams();
//     const [userData, setUserData] = useState({
//         username: '',
//         email: '',
//         first_name: '',
//         last_name: '',
//         contact: '',
//         trainer: ''
//     });
//     const [trainers, setTrainers] = useState([]);
//     const [selectedTrainer, setSelectedTrainer] = useState('No Trainer');
//     const [selectedTrainerid, setSelectedTrainerid] = useState('No Trainer');
//     const [trainerFee, setTrainerFee] = useState('');
//     const navigate = useNavigate();
//     const { user } = useContext(AuthContext);

//     useEffect(() => {
//         getUserData(user.user_id, id);
//         if (selectedTrainer != '') {
//             const temp = selectedTrainer.split('-');
//             var tempId = temp[0];
//             setSelectedTrainerid(parseInt(tempId))
//             var tempName = temp[1];
//             var tempFee = temp[2];
//             if (tempName !== 'No Trainer' && tempName !== '') {
//                 setSelectedTrainerid(tempId);
//                 // setTrainerFee(`Trainer Monthly Fees: ${tempFee.toLocaleString()}`)
//             }
//             else if (selectedTrainerid === 'No Trainer') {
//                 return null
//             }
//         }
//     }, [selectedTrainer]);

//     const getUserData = async (adminID, userID) => {
//         try {
//             const userResponse = await axios.get(`http://192.168.1.13:8001/api/get-user/${userID}/`);
//             setUserData({
//                 username: userResponse.data.username,
//                 email: userResponse.data.email,
//                 first_name: userResponse.data.first_name,
//                 last_name: userResponse.data.last_name,
//                 contact: userResponse.data.contact || '',
//                 trainer: userResponse.data.trainer || 'No Trainer'
//             });

//             const adminResponse = await axios.get(`http://192.168.1.13:8001/api/admin/${adminID}/`);
//             getTrainers(adminResponse.data.gym);
//         } catch (err) {
//             console.error(err);
//         }
//     };

//     const getTrainers = async (gymID) => {
//         try {
//             const response = await axios.get(`http://192.168.1.13:8001/api/gym-trainers/${gymID}`);
//             setTrainers(response.data);
//         } catch (err) {
//             console.error(err);
//         }
//     };

//     useEffect(() => {
//         if (selectedTrainer) {
//             const [trainerID, trainerName, trainerFee] = selectedTrainer.split('-');
//             setTrainerFee(trainerName !== 'No Trainer' ? `Trainer Monthly Fees: ${trainerFee}` : '');
//         }
//     }, [selectedTrainer]);

//     const handleUpdate = async (e) => {
//         e.preventDefault();
//         try {
//             await axios.put(`http://192.168.1.13:8001/api/update-user/${id}/`, {
//                 ...userData,
//                 trainer: selectedTrainer.split('-')[0],
//             });
//             navigate('/');
//         } catch (error) {
//             console.error('Error updating user data:', error);
//         }
//     };

//     return (
//         <Sidebar pageName="Edit User">
//             <div>
//                 <p className='text-3xl font-bold px-5 py-10 uppercase'>Edit Member</p>
//             </div>
//             <form onSubmit={handleUpdate}>
//                 <div className='flex flex-col'>
//                     <div>
//                         <input
//                             type="text"
//                             name="username"
//                             placeholder='Username'
//                             value={userData.username}
//                             onChange={(e) => setUserData({ ...userData, username: e.target.value })}
//                             className='input-field'
//                         />
//                         <input
//                             type="email"
//                             name="email"
//                             placeholder='Email'
//                             value={userData.email}
//                             onChange={(e) => setUserData({ ...userData, email: e.target.value })}
//                             className='input-field'
//                         />
//                     </div>
//                     <div>
//                         <input
//                             type="text"
//                             name="first_name"
//                             placeholder='First Name'
//                             value={userData.first_name}
//                             onChange={(e) => setUserData({ ...userData, first_name: e.target.value })}
//                             className='input-field'
//                         />
//                         <input
//                             type="text"
//                             name="last_name"
//                             placeholder='Last Name'
//                             value={userData.last_name}
//                             onChange={(e) => setUserData({ ...userData, last_name: e.target.value })}
//                             className='input-field'
//                         />
//                     </div>
//                     <div>
//                         <input
//                             type="tel"
//                             name="contact"
//                             placeholder='Contact Number'
//                             value={userData.contact}
//                             onChange={(e) => setUserData({ ...userData, contact: e.target.value })}
//                             className='input-field'
//                         />
//                     </div>
//                     <div>
//                         <select
//                             name="trainer"
//                             value={selectedTrainer}
//                             onChange={(e) => setSelectedTrainer(e.target.value)}
//                             className='input-field'
//                         >
//                             <option value="No Trainer">No Trainer</option>
//                             {trainers.map((trainer, index) => (
//                                 <option key={index} value={`${trainer.id}-${trainer.first_name} ${trainer.last_name}-${trainer.monthly_charges}`}>
//                                     {trainer.first_name} {trainer.last_name}
//                                 </option>
//                             ))}
//                         </select>
//                         <input
//                             hidden
//                             type="text"
//                             name="gym_id"
//                             value={userData.gym}
//                             readOnly
//                             className='input-field'
//                         />
//                         <button type="submit" className='submit-button'>Update</button>
//                     </div>
//                     <div className='fee-display'>
//                         {trainerFee}
//                     </div>
//                 </div>
//             </form>
//         </Sidebar>
//     );
// };

// export default EditUser;

import React, { useContext, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import AuthContext from '../Context/AuthContext';
import axios from 'axios';
import Sidebar from '../Components/Sidebar';

const EditUser = () => {
    const { id } = useParams();
    const [userData, setUserData] = useState({
        username: '',
        email: '',
        first_name: '',
        last_name: '',
        contact: '',
        trainer: 'No Trainer'
    });
    const [trainers, setTrainers] = useState([]);
    const [selectedTrainer, setSelectedTrainer] = useState('No Trainer');
    const [trainerFee, setTrainerFee] = useState('');
    const navigate = useNavigate();
    const { user } = useContext(AuthContext);

    useEffect(() => {
        getUserData(user.user_id, id);
    }, [id]);

    useEffect(() => {
        if (typeof selectedTrainer === 'string' && selectedTrainer !== 'No Trainer') {
            const [trainerID, trainerName, trainerFee] = selectedTrainer.split('-');
            setTrainerFee(trainerName ? `Trainer Monthly Fees: ${trainerFee}` : '');
        }
    }, [selectedTrainer]);

    const getUserData = async (adminID, userID) => {
        try {
            const userResponse = await axios.get(`http://192.168.1.13:8001/api/get-user/${userID}/`);
            const user = userResponse.data;
            setUserData({
                username: user.username,
                email: user.email,
                first_name: user.first_name,
                last_name: user.last_name,
                contact: user.contact || '',
                trainer: user.trainer ? `${user.trainer.id}-${user.trainer.first_name} ${user.trainer.last_name}-${user.trainer.monthly_charges}` : 'No Trainer'
            });

            const adminResponse = await axios.get(`http://192.168.1.13:8001/api/admin/${adminID}/`);
            getTrainers(adminResponse.data.gym);
        } catch (err) {
            console.error(err);
        }
    };

    const getTrainers = async (gymID) => {
        try {
            const response = await axios.get(`http://192.168.1.13:8001/api/gym-trainers/${gymID}`);
            setTrainers(response.data);
        } catch (err) {
            console.error(err);
        }
    };

    const handleUpdate = async (e) => {
        e.preventDefault();
        try {
            const updateData = { ...userData };
            if (selectedTrainer !== 'No Trainer') {
                const trainerID = selectedTrainer.split('-')[0];
                updateData.trainer = trainerID;
            } else {
                updateData.trainer = null;
            }
            delete updateData.username; // Prevent username from being sent
            await axios.put(`http://192.168.1.13:8001/api/update-user/${id}/`, updateData);
            navigate('/');
        } catch (error) {
            console.error('Error updating user data:', error);
        }
    };

    return (
        <Sidebar pageName="User">
            <div>
                <p className='text-3xl font-bold px-5 py-10 uppercase'>Edit Member</p>
            </div>
            <form onSubmit={handleUpdate}>
                <div className='flex flex-col'>
                    <div>
                        <input
                            type="text"
                            name="username"
                            placeholder='Username'
                            value={userData.username}
                            readOnly
                            className='input-field'
                        />
                        <input
                            type="email"
                            name="email"
                            placeholder='Email'
                            value={userData.email}
                            onChange={(e) => setUserData({ ...userData, email: e.target.value })}
                            className='input-field'
                        />
                    </div>
                    <div>
                        <input
                            type="text"
                            name="first_name"
                            placeholder='First Name'
                            value={userData.first_name}
                            onChange={(e) => setUserData({ ...userData, first_name: e.target.value })}
                            className='input-field'
                        />
                        <input
                            type="text"
                            name="last_name"
                            placeholder='Last Name'
                            value={userData.last_name}
                            onChange={(e) => setUserData({ ...userData, last_name: e.target.value })}
                            className='input-field'
                        />
                    </div>
                    <div>
                        <input
                            type="tel"
                            name="contact"
                            placeholder='Contact Number'
                            value={userData.contact}
                            onChange={(e) => setUserData({ ...userData, contact: e.target.value })}
                            className='input-field'
                        />
                    </div>
                    <div>
                        <select
                            name="trainer"
                            value={selectedTrainer}
                            onChange={(e) => setSelectedTrainer(e.target.value)}
                            className='input-field'
                        >
                            <option value="No Trainer">No Trainer</option>
                            {trainers.map((trainer, index) => (
                                <option key={index} value={`${trainer.id}-${trainer.first_name} ${trainer.last_name}-${trainer.monthly_charges}`}>
                                    {trainer.first_name} {trainer.last_name}
                                </option>
                            ))}
                        </select>
                        <button type="submit" className='submit-button'>Update</button>
                    </div>
                    <div className='fee-display'>
                        {trainerFee}
                    </div>
                </div>
            </form>
        </Sidebar>
    );
};

export default EditUser;
