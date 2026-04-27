import React, { useContext, useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom';
import AuthContext from '../Context/AuthContext'
import axios from 'axios'
import Sidebar from '../Components/Sidebar'

const AddExercise = () => {
    const [userData, setUserData] = useState([])
    const [gymID, setGymID] = useState();
    const [image, setImage] = useState(null);
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
    const handleImageChange = (e) => {
        setImage(e.target.files[0]);
    };

    let addExercise = async (e) => {
        // e.preventDefault()
        //     console.log('Add Exercise Form Submitted.')
        //     console.log(e.target.image.value)
        //     let response = await axios.post('http://192.168.1.13:8001/api/add-exercise/', { 'name': e.target.name.value, 'exercise_type': e.target.exercise_type.value, 'image': image, 'description': e.target.description.value, 'gym_id': e.target.gym_id.value })
        //     console.log(response.data)

        //     if (response.status === 200) {
        //         alert('Exercise Added Successfully!')
        //         return 'success'
        //     }
        //     else {
        //         alert('Something went wrong')
        //     }
        // }
        const formData = new FormData();
        formData.append('name', e.target.name.value);
        formData.append('exercise_type', e.target.exercise_type.value);
        formData.append('image', image);
        formData.append('description', e.target.description.value);
        formData.append('gym_id', e.target.gym_id.value);

        try {
            let response = await axios.post('http://192.168.1.13:8001/api/add-exercise/', formData);
            console.log(response.data);

            if (response.status === 200) {
                alert('Exercise Added Successfully!');
                return 'success';
            } else {
                alert('Something went wrong');
            }
        } catch (error) {
            console.error('Error adding exercise:', error);
            alert('Error adding exercise. Please try again.');
        }
    };

    const handleForm = async (e) => {
        e.preventDefault();
        const response = await addExercise(e);
        if (response === 'success') {
            // navigate('/')
            alert('Equipment Added Successfully')
        }
    };
    return (
        <section className=' sm:ml-64 sm:mt-16'>
            <form onSubmit={handleForm} encType='multipart/form-data'>
                <div className='flex flex-col '>
                    <div>
                        <input type="text" name="name" id="name" placeholder='Enter Exercise Name' className='w-1/4 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

                        <input type="text" name="exercise_type" id="exercise_type" placeholder='Enter Exercise Type' className='w-1/4 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

                    </div>
                    <div>
                        <input type="file" name="image" id="image" onChange={handleImageChange} placeholder='Enter Exercise Image' className='w-1/4 py-3  my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

                        <input type="text" name="description" id="description" placeholder='Enter Exercise Description' className='w-1/4 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
                    </div>
                    <input hidden={true} type="text" name="gym_id" id="gym_id" placeholder='Enter gym' className='w-1/4 py-3 px-2 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' defaultValue={gymID} value={gymID} />



                    <button className='w-1/4 border-none px-10 py-3 m-5 bg-lime-400 rounded-lg font-bold' onClick={() => { }}>ADD</button>
                </div>
            </form>
        </section>
    )
}
export default AddExercise