import {
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  HostBinding,
  Input,
} from '@angular/core';
import { populateInputsFromDataset } from 'core-app/shared/components/dataset-inputs';
import { CurrentUserService } from 'core-app/core/current-user/current-user.service';
import { CurrentProjectService } from 'core-app/core/current-project/current-project.service';
import { UntilDestroyedMixin } from 'core-app/shared/helpers/angular/until-destroyed.mixin';
import { I18nService } from 'core-app/core/i18n/i18n.service';
import { BannersService } from 'core-app/core/enterprise/banners.service';
import { map } from 'rxjs/operators';
import { CapabilitiesResourceService } from 'core-app/core/state/capabilities/capabilities.service';

export const opTeamPlannerSidemenuSelector = 'op-team-planner-sidemenu';

@Component({
  selector: opTeamPlannerSidemenuSelector,
  templateUrl: './team-planner-sidemenu.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TeamPlannerSidemenuComponent extends UntilDestroyedMixin {
  @HostBinding('class.op-sidebar') className = true;

  @Input() menuItems:string[] = [];

  @Input() projectId:string|undefined;

  canAddTeamPlanner$ = this
    .capabilitiesService
    .hasCapabilities$(
      'team_planners/create',
      this.currentProjectService.id || undefined,
    )
    .pipe(
      map((val) => val && !this.bannersService.eeShowBanners),
    );

  createButton = {
    text: this.I18n.t('js.team_planner.create_label'),
    title: this.I18n.t('js.team_planner.create_title'),
    uiSref: 'team_planner.page.show',
    uiParams: {
      query_id: null,
      query_props: '',
    },
  };

  constructor(
    readonly elementRef:ElementRef,
    readonly currentUserService:CurrentUserService,
    readonly capabilitiesService:CapabilitiesResourceService,
    readonly currentProjectService:CurrentProjectService,
    readonly bannersService:BannersService,
    readonly I18n:I18nService,
  ) {
    super();

    populateInputsFromDataset(this);
  }
}
