import React, { useContext, useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom';
import AuthContext from '../Context/AuthContext'
import axios from 'axios'
import Sidebar from '../Components/Sidebar'

const AddEquipment = () => {
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

  let addEquipment = async (e) => {
    // e.preventDefault()
    console.log('Add Equipment Form Submitted.')
    let response = await axios.post('http://192.168.1.13:8001/api/add-equipment/', { 'name': e.target.name.value, 'category': e.target.category.value, 'quantity': e.target.quantity.value, 'description': e.target.description.value, 'gym_id': e.target.gym_id.value })
    console.log(response.data)

    if (response.status === 200) {
      alert('Equipment Added Successfully!')
      return 'success'
    }
    else {
      alert('Something went wrong')
    }
  }

  const handleForm = async (e) => {
    e.preventDefault();
    const response = await addEquipment(e);
    if (response === 'success') {
      // navigate('/')
      alert('Equipment Added Successfully')
    }
  };
  return (
    <Sidebar pageName="Add Equipment">
      <form className='bg-main p-8 rounded-lg' onSubmit={handleForm}>
          <div className='grid grid-cols-1 gap-10 flex-wrap'>
          <div>
          <input type="text" name="name" id="name" placeholder='Enter Equipment Name' className='w-1/3 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

          <input type="text" name="category" id="category" placeholder='Enter Equipment Category' className='w-1/3 py-3 px-2 mx-5 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
          </div>
          <div>
          <input type="number" name="quantity" id="quantity" placeholder='Enter Equipment Quantity' className='w-1/3 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />

          <input type="text" name="description" id="description" placeholder='Enter Equipment Description' className='w-1/3 py-3 px-2 my-5 mx-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' />
          </div>
          <input hidden={true} type="text" name="gym_id" id="gym_id" placeholder='Enter gym' className='t w-1/4 py-3 px-2 my-5 bg-transparent border-[1px] border-stone-300 rounded-md text-stone-950' defaultValue={gymID} value={gymID} />
        
          <button className='w-1/4 border-none px-10 py-3 m-5 bg-lime-400 rounded-lg font-bold text-black' onClick={() => { }}>ADD</button>

        </div>



      </form>
    </Sidebar>
  )
}

export default AddEquipment