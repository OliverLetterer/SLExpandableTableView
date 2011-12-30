//
//  UICollapsingTableViewCell.m
//  iGithub
//
//  Created by me on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCollapsingAndSpinningTableViewCell.h"


@implementation GHCollapsingAndSpinningTableViewCell

@synthesize activityIndicatorView=_activityIndicatorView, disclosureIndicatorImageView=_disclosureIndicatorImageView;

#pragma mark - Initialization

- (void)setSpinning:(BOOL)spinning {
    _isSpinning = spinning;
    if (spinning) {
        self.accessoryView = self.activityIndicatorView;
    } else {
        self.accessoryView = self.disclosureIndicatorImageView;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.disclosureIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicator.PNG"]];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicatorView startAnimating];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.disclosureIndicatorImageView.image = [UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicatorSelected.PNG"];
    } else {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.disclosureIndicatorImageView.image = [UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicator.PNG"];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.disclosureIndicatorImageView.image = [UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicatorSelected.PNG"];
    } else {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.disclosureIndicatorImageView.image = [UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicator.PNG"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.accessoryView.center = CGPointMake(15.0, 22.0);
    self.textLabel.frame = CGRectMake(27.0, 0.0, self.contentView.bounds.size.width-27.0, 44.0);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)setLoading:(BOOL)loading {
    [self setSpinning:loading];
}

- (void)setExpansionStyle:(UIExpansionStyle)style animated:(BOOL)animated
{
    void(^animationBlock)(void) = ^(void) {
        self.accessoryView = self.disclosureIndicatorImageView;
        switch (style) {
            case UIExpansionStyleExpanded:
                self.accessoryView.transform = CGAffineTransformIdentity;
                break;
            case UIExpansionStyleCollapsed:
                self.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
                break;
                
            default:
                break;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animationBlock];
    } else {
        animationBlock();
    }
}

@end
