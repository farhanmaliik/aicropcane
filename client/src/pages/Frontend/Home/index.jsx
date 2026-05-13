import React from 'react'
import HeroSection from '../../../components/HeroSection'
import OverviewSection from '../../../components/OverviewSection'
import PlantGuidesSection from '../../../components/PlantGuidesSection'
import ReviewsSection from '../../../components/ReviewsSection'
import FaqsSection from '../../../components/FaqsSection'

export default function Home() {
    return (
        <>
            <HeroSection />
            <OverviewSection />
            <PlantGuidesSection />
            <ReviewsSection />
            <FaqsSection />
        </>
    )
}