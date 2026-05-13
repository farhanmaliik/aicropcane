import React from 'react'
import './loader.css'

export default function Loader() {
    return (
        <div className='w-full min-h-screen flex flex-col justify-center items-center gap-4 bg-white'>
            <span className='text-2xl font-bold text-green-600 tracking-wide'>🌿 AI Crop Cane</span>
            <div className="loader"></div>
        </div>
    )
}