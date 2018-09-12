//
//  EventsCollectionViewCell.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/12/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import CircleProgressView
import SwifterSwift

class EventsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var daysCircleProgressView: CircleProgressView!
    @IBOutlet weak var hoursCircleProgressView: CircleProgressView!
    @IBOutlet weak var minutesCircleProgressView: CircleProgressView!
    @IBOutlet weak var secondsCircleProgressView: CircleProgressView!
    
    @IBOutlet weak var daysCounterLabel: UILabel!
    @IBOutlet weak var hoursCounterLabel: UILabel!
    @IBOutlet weak var minutesCounterLabel: UILabel!
    @IBOutlet weak var secsCounterLabel: UILabel!
    
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minsLabel: UILabel!
    @IBOutlet weak var secsLabel: UILabel!
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventStatusLabel: UILabel!
    
    var timeDue: Date?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        customizeUI()

    }
    
    fileprivate func customizeUI()
    {
        customizeTimeLabels()
        customizeHeaderAndFooter()
    }
    
    func setEvent(event: Event)
    {
        eventTitleLabel.text = event.eventTitle
        if event.eventImageString != nil //if there is an image, use it, else use the placeholder
        {eventImageView.image = UIImage(named: event.eventImageString!)}
        switch event.eventStatus
        {
        case .anticipated:
            handleEventIsAnticipatedCase(eventDueDateString: event.eventDueDate)
            break
        case .hasFinished:
            handleEventIsFinishedCase()
        case .onGoing:
            handleEventIsOnGoingCase()
        default:
            fatalError("Easter Egg: You are never supposed to be here CAAAARL")
            //No break needed here
        }
    }
    
    private func handleEventIsAnticipatedCase(eventDueDateString: String)
    {
        eventStatusLabel.text = "We are waiting for it too!"
        timeDue = Date(timeInterval: eventDueDateString.toDate(format: "yyyy-MM-dd HH:mm:ss").timeIntervalSince(Date()), since: Date())
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setTimeLeft), userInfo: nil, repeats: true)
    }
    
    private func handleEventIsOnGoingCase()
    {
        daysCounterLabel.text = "On"
        hoursCounterLabel.text = "GO"
        minutesCounterLabel.text = "iN"
        secsCounterLabel.text = "G"
        
        daysCounterLabel.textColor = UIColor.red
        hoursCounterLabel.textColor = UIColor.red
        minutesCounterLabel.textColor = UIColor.red
        secsCounterLabel.textColor = UIColor.red
        
        daysCircleProgressView.setProgress(1, animated: true)
        daysCircleProgressView.trackFillColor = UIColor.red
        hoursCircleProgressView.setProgress(1, animated: true)
        hoursCircleProgressView.trackFillColor = UIColor.red
        minutesCircleProgressView.setProgress(1, animated: true)
        minutesCircleProgressView.trackFillColor = UIColor.red
        secondsCircleProgressView.setProgress(1, animated: true)
        secondsCircleProgressView.trackFillColor = UIColor.red
        
        eventStatusLabel.text = "Event is On Going!"
        eventStatusLabel.textColor = UIColor.red
    }
    
    private func handleEventIsFinishedCase()
    {
        daysCounterLabel.text = "D"
        hoursCounterLabel.text = "O"
        minutesCounterLabel.text = "N"
        secsCounterLabel.text = "E"
        
        daysCounterLabel.textColor = UIColor.green
        hoursCounterLabel.textColor = UIColor.green
        minutesCounterLabel.textColor = UIColor.green
        secsCounterLabel.textColor = UIColor.green
        
        daysCircleProgressView.setProgress(1, animated: true)
        daysCircleProgressView.trackFillColor = UIColor.green
        hoursCircleProgressView.setProgress(1, animated: true)
        hoursCircleProgressView.trackFillColor = UIColor.green
        minutesCircleProgressView.setProgress(1, animated: true)
        minutesCircleProgressView.trackFillColor = UIColor.green
        secondsCircleProgressView.setProgress(1, animated: true)
        secondsCircleProgressView.trackFillColor = UIColor.green
        
        eventStatusLabel.text = "Event Has Ended!"
        eventStatusLabel.textColor = UIColor.green
        
    }
    
    fileprivate func customizeTimeLabels()
    {
        daysLabel.layer.masksToBounds = !daysLabel.layer.masksToBounds
        daysLabel.layer.borderWidth = 1
        daysLabel.layer.cornerRadius = 10
        daysLabel.layer.borderColor = #colorLiteral(red: 0.983099997, green: 0.5982919885, blue: 0.03144000097, alpha: 1)
        
        hoursLabel.layer.masksToBounds = !hoursLabel.layer.masksToBounds
        hoursLabel.layer.borderWidth = 1
        hoursLabel.layer.cornerRadius = 10
        hoursLabel.layer.borderColor = #colorLiteral(red: 0.983099997, green: 0.5982919885, blue: 0.03144000097, alpha: 1)
        
        minsLabel.layer.masksToBounds = !minsLabel.layer.masksToBounds
        minsLabel.layer.borderWidth = 1
        minsLabel.layer.cornerRadius = 10
        minsLabel.layer.borderColor = #colorLiteral(red: 0.983099997, green: 0.5982919885, blue: 0.03144000097, alpha: 1)
        
        secsLabel.layer.masksToBounds = !secsLabel.layer.masksToBounds
        secsLabel.layer.borderWidth = 1
        secsLabel.layer.cornerRadius = 10
        secsLabel.layer.borderColor = #colorLiteral(red: 0.983099997, green: 0.5982919885, blue: 0.03144000097, alpha: 1)
    }
    
    fileprivate func customizeHeaderAndFooter()
    {
        eventTitleLabel.roundCorners([.topLeft,.topRight], radius: 10)
        eventStatusLabel.roundCorners([.bottomLeft, .bottomRight], radius: 10)
    }

    
    fileprivate func setTimeDue(date: Date)
    {
        timeDue = date
    }
    
    @objc func setTimeLeft() {
        
        let currentTime = Date()
        
        if timeDue?.compare(currentTime) == ComparisonResult.orderedDescending
        {
            
            let interval = timeDue?.timeIntervalSince(currentTime)
            
            let days =  (interval! / (60*60*24)).rounded(.down)
            
            let daysRemainder = interval?.truncatingRemainder(dividingBy: 60*60*24)
            
            let hours = (daysRemainder! / (60 * 60)).rounded(.down)
            
            let hoursRemainder = daysRemainder?.truncatingRemainder(dividingBy: 60 * 60).rounded(.down)
            
            let minutes  = (hoursRemainder! / 60).rounded(.down)
            
            let minitesRemainder = hoursRemainder?.truncatingRemainder(dividingBy: 60).rounded(.down)
            
            let secounds = minitesRemainder?.truncatingRemainder(dividingBy: 60).rounded(.down)
            
            daysCircleProgressView.setProgress(days/Double((Date().end(of: .month)?.day)!), animated: true)
            hoursCircleProgressView.setProgress(hours/24, animated: true)
            minutesCircleProgressView.setProgress(minutes/60, animated: true)
            secondsCircleProgressView.setProgress(secounds!/60, animated: true)
            
            let formatter = NumberFormatter()
            formatter.minimumIntegerDigits = 2
            
            daysCounterLabel.text = formatter.string(from: NSNumber(value:days))
            hoursCounterLabel.text = formatter.string(from: NSNumber(value:hours))
            minutesCounterLabel.text = formatter.string(from: NSNumber(value:minutes))
            secsCounterLabel.text = formatter.string(from: NSNumber(value:secounds!))
        }
    }

}

extension String{
    func toDate(format : String) -> Date
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)!
    }
}

extension UIView {
    func fadeIn() {
        // Move our fade out code from earlier
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
        }, completion: nil)
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
}
