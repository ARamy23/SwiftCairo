//
//  EventsViewController.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/13/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

struct Event
{
    enum EventStatus
    {
        case onGoing
        case hasFinished
        case anticipated
    }
    let eventTitle: String
    let eventImageString: String?
    let eventDueDate: String
    let eventStatus: EventStatus
}


class EventsViewController: UIViewController
{
    
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    
    let events: [Event] = [Event(eventTitle: "Code Reading Session",eventImageString: "Code-Reading Event", eventDueDate: "2018-05-19 20:00:00", eventStatus: .anticipated)]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    fileprivate func setupUI()
    {
        navigationController?.navigationBar.topItem?.title = "Hall of Events"
        
    }
    
    func initCollectionView()
    {
        eventsCollectionView.register(UINib(nibName: "EventsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EventsCollectionViewCell")
    }

}

extension EventsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventsCollectionView.dequeueReusableCell(withReuseIdentifier: "EventsCollectionViewCell", for: indexPath) as! EventsCollectionViewCell
        cell.setEvent(event: events[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return eventsCollectionView.frame.size
    }
    
    
}
